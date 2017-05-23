require 'git-version-bump'
Dir[File.join(__dir__,"releaseme", "services", "**", "*.rb")].each {|file| require file }
require_relative 'releaseme/configuration'
require 'logger'

module ReleaseMe


  # pass ing config object which can be formed passing in hash and splat of key=val items
  # deployment_id = job_template_id for tower that you wish to start
  #
  #
  #
  def self.deploy_and_publish!(deployment_id, config, branch_name = :current)

    if branch_name == :current
      branch_name = $1 if `git branch` =~ /\* (\S+)\s/m
    end

    tower_mgr = ReleaseMe::Services::DeploymentManagers::TowerManager.new(config.deployment_manager_site_url,config.deployment_manager_username, config.deployment_manager_password)

    job_opts = {"git_branch" => branch_name, "ansible_user" => "ubuntu"}

    job_opts.merge!(config.deployment_manager_options)

    tag_info = ReleaseMe::tag_version(config)

    status = tower_mgr.start_job_from_template(deployment_id,job_opts)

    ReleaseMe::publish(config, tag_info) if status == "successful"

  end

  def self.publish_event(config, event_title, event_description, tags = [])

    if config.publishers_config[:datadog].has_key?(:api_key)
      api_key = config.publishers_config[:datadog][:api_key]

      events = ReleaseMe::Services::Publishers::DatadogPublisher.new(api_key)

      tags << "environment:#{config.environment_to_deploy}"

      events.publish_event(event_title,event_description,tags)
    end


  end

  # return a Hash with new_version, old_version
  def self.tag_version(config)
    logger = Logger.new(STDOUT)
    version_increase = config.version_increase

    old_version = "v#{GVB.major_version(true)}.#{GVB.minor_version(true)}.#{GVB.patch_version(true)}"

    unless version_increase == 'none'
      logger.info "current version tag #{old_version}"
      if version_increase == 'major'
        GVB.tag_version "#{GVB.major_version(true) + 1}.0.0"
      elsif version_increase == 'minor'
        GVB.tag_version "#{GVB.major_version(true)}.#{GVB.minor_version(true)+1}.0"
      elsif version_increase == 'patch'
        GVB.tag_version "#{GVB.major_version(true)}.#{GVB.minor_version(true)}.#{GVB.patch_version(true)+1}"
      end

      logger.info "version tag bumped to #{GVB.version(true)}"
    end

    if version_increase == 'none'
      new_version = old_version
    else
      new_version = "v#{GVB.major_version(true)}.#{GVB.minor_version(true)}.#{GVB.patch_version(true)}"
    end


    {:old_version => old_version, :new_version => new_version}

  end

  def self.publish(config, tag_info)
    logger = Logger.new(STDOUT)

    git_working_directory = config.git_working_directory
    version_increase = config.version_increase

    old_version = tag_info[:old_version]
    story_ids = []

    unless git_working_directory == :working_directory_not_set
      git_mgr = ReleaseMe::Services::SourceManagers::GitManager.new(git_working_directory)
      new_version = tag_info[:new_version]

      if git_mgr.tag_exists(old_version)
        if new_version == old_version
          if config.environment_to_deploy == 'production'
            recent_tags = `git tag --sort -v:refname | head -2`.split("\n")
            commits = git_mgr.get_commits(recent_tags[1], recent_tags[0])
            story_ids = git_mgr.get_story_ids(commits)
            logger.info "story ids found for this production release #{story_ids.length} stories"
          end
        else
          logger.info "getting commits between #{old_version} and #{new_version}"
          commits = git_mgr.get_commits(old_version, new_version) unless version_increase == 'none'
          story_ids = git_mgr.get_story_ids(commits)
          logger.info "story ids found for this release #{story_ids.length} stories"
        end

      end

    end

    jira_site_url = config.issue_tracker_site_url
    jira_username = config.issue_tracker_username
    jira_passwword = config.issue_tracker_password

    tracker = ReleaseMe::Services::IssueTrackers::JiraTracker.new(jira_site_url, jira_username, jira_passwword)

    issues = tracker.get_issues(story_ids)
    output = ''
    issues.each{|i| output << "#{i.id} - #{i.title}\n"  }

    if issues.length > 0
      logger.info " #{issues.length} issues loaded from JIRA"
      logger.info "**** RELEASE NOTES FOR #{new_version}*****"
      logger.info output
      logger.info "****** END RELEASE NOTES *********"

    end

    logger.info "going to publish to #{config.publishers.inspect} publishers"

    config.publishers.each do |publisher|

      if publisher == :hipchat
        unless config.publishers_config[publisher][:api_token] == :publisher_api_token_not_set
          logger.info "publishing release info to hipchat"
          pub = ReleaseMe::Services::Publishers::HipChatPublisher.new(config.publishers_config[publisher][:api_token])
          env_to_deploy = config.environment_to_deploy

          pub.publish_release(new_version, config.publisher_system_name,env_to_deploy,config.publishers_config[publisher][:chat_room],issues)

        end
      elsif publisher == :jira
        logger.info 'publishing release comments to JIRA stories'
        pub = ReleaseMe::Services::Publishers::JiraPublisher.new(tracker)
        pub.publish_release(new_version,config.environment_to_deploy,issues)
      elsif publisher == :datadog

        #broadcast build announcement with tag , which is in variable new_version
        if config.publishers_config[publisher].has_key?(:api_key)
          api_key = config.publishers_config[publisher][:api_key]
          logger.info "publishing event to datadog"
          events = ReleaseMe::Services::Publishers::DatadogPublisher.new(api_key)
          events.publish_release(new_version,config.publisher_system_name,config.environment_to_deploy)
        end

      end

    end


  end





end
