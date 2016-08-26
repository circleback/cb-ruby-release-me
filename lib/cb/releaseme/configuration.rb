
module ReleaseMe

  class Configuration

    attr :issue_tracker
    attr :issue_tracker_username
    attr :issue_tracker_password
    attr :issue_tracker_site_url
    attr :source_manager
    attr :git_working_directory
    attr :version_increase

    attr :publisher
    attr :publisher_api_token
    attr :publisher_chat_room
    attr :publisher_system_name
    attr :environment_to_deploy

    attr :deployment_manager_site_url
    attr :deployment_manager_username
    attr :deployment_manager_password

    def initialize(config_opts = {}, *key_value_args)

      initial_config = ReleaseMe::Configuration::load_default_configuration
      initial_config.merge!(config_opts)

      has_version_increase_key = config_opts.has_key?("version_increase")

      key_value_args.each do |a|
        key_value = a.split("=")
        if key_value.length == 2
          if key_value.first == "version_increase"
            has_version_increase_key = true
          end
          initial_config[key_value.first] = key_value.last
        end
      end

      unless has_version_increase_key

        if initial_config['environment_to_deploy'] == 'qa'
          initial_config['version_increase'] = 'patch'
        elsif initial_config['environment_to_deploy'] == 'production'
          initial_config['version_increase'] = 'none'
        end

      end

      initial_config.each_pair{|k,v| instance_variable_set(:"@#{k}", v)  }

    end


    def self.load_default_configuration
      config = {}

      config[:issue_tracker] = :jira
      config[:issue_tracker_username] = ENV['JIRA_USERNAME']
      config[:issue_tracker_password]= ENV['JIRA_PASSWORD']
      config[:issue_tracker_site_url]= 'https://circleback.atlassian.net'

      config[:source_manager]=  :git
      config[:git_working_directory]=  :working_directory_not_set

      default_version_increase = ENV['version_increase']
      default_version_increase ||= 'patch'
      config[:version_increase] =  default_version_increase

      config[:publisher]=  :hip_chat
      config[:publisher_api_token]=  :publisher_api_token_not_set
      config[:publisher_chat_room]=  :publisher_chat_room_not_set
      config[:publisher_system_name]=  :publisher_system_name_not_set
      config[:environment_to_deploy]= ENV['rack_env']

      config[:deployment_manager_site_url] = 'https://tower.ops.circleback.com/api/v1/'
      config[:deployment_manager_username] = ENV['ANSIBLE_TOWER_USER']
      config[:deployment_manager_password] = ENV['ANSIBLE_TOWER_PWD']

      config

    end



  end


end