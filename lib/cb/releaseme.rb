require 'git-version-bump'
#require 'git-version-bump/rake-tasks'
Dir[File.join(__dir__, "services", "**", "*.rb")].each {|file| require file }
require_relative 'releaseme/configuration'


module ReleaseMe


  def publish(config = ReleaseMe::Configuration.new)


    git_working_directory = config.git_working_directory
    version_increase = config.version_increase

    old_version = "v#{GVB.major_version(true)}.#{GVB.minor_version(true)}.#{GVB.patch_version(true)}"
    story_ids = []

    unless version_increase == 'none'
      info "current version tag #{old_version}"
      if version_increase == 'major'
        GVB.tag_version "#{GVB.major_version(true) + 1}.0.0"
      elsif version_increase == 'minor'
        GVB.tag_version "#{GVB.major_version(true)}.#{GVB.minor_version(true)+1}.0"
      elsif version_increase == 'patch'
        GVB.tag_version "#{GVB.major_version(true)}.#{GVB.minor_version(true)}.#{GVB.patch_version(true)+1}"
      end

      info "version tag bumped to #{GVB.version(true)}"
    end

    unless git_working_directory == :working_directory_not_set
      git_mgr = Services::SourceManagers::GitManager.new(git_working_directory)
      new_version = "v#{GVB.major_version(true)}.#{GVB.minor_version(true)}.#{GVB.patch_version(true)}"

      if git_mgr.tag_exists(old_version)
        unless new_version == old_version
          info "getting commits between #{old_version} and #{new_version}"
          commits = git_mgr.get_commits(old_version, new_version) unless version_increase == 'none'
          story_ids = git_mgr.get_story_ids(commits)
          info "story ids found for this release #{story_ids.length} stories"
        end
      end

    end

    jira_site_url = config.issue_tracker_site_url
    jira_username = config.issue_tracker_username
    jira_passwword = config.issue_tracker_password

    tracker = Services::IssueTrackers::JiraTracker.new(jira_site_url, jira_username, jira_passwword)

    issues = tracker.get_issues(story_ids)
    output = ''
    issues.each{|i| output << "#{i.id} - #{i.title}\n"  }

    if issues.length > 0
      info " #{issues.length} issues loaded from JIRA"
      info "**** RELEASE NOTES FOR #{new_version}*****"
      info output
      info "****** END RELEASE NOTES *********"

    end

    publisher_api_token = config.publisher_api_token
    unless publisher_api_token == :publisher_api_token_not_set

      pub = Services::Publishers::HipChatPublisher.new(publisher_api_token)
      env_to_deploy = config.env_to_deploy

      pub.publish_release(new_version, config.publisher_system_name,env_to_deploy,config.publisher_chat_room,issues)

    end





  end





end
