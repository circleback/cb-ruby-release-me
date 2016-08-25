require_relative '../../lib/cb-releaseme'


namespace :releaseme do
  desc 'replaces the capistrano deployment method, will call into ansible tower to handle deployment, rake deploy[production,instance_size=xlarge,immutable=false,version_increase=major|minor|none|patch]. Last two params are optional'
  task :deploy,[:environment]  do |t,args|

    job_options = {}
    version_increase = 'none'

    args.extras.each do |a|
      key_value = a.split("=")
      if key_value.length == 2
        job_options[key_value.first] = key_value.last
      end
    end

    if args[:environment] == "production"
      version_increase = 'none'
      job_options["environment_to_deploy"] = args[:environment]
    elsif args[:environment] == "qa"
      version_increase = 'patch'
      job_options["environment_to_deploy"] = args[:environment]
    end

    deployment_id = job_options["deployment_id"]
    job_options["version_increase"] = version_increase unless job_options["version_increase"]

    ReleaseMe::deploy_and_publish!(deployment_id, :current, job_options)



    #puts "I am in this task"
    #puts "version increase passed in is #{version_increase} and environment is #{args[:environment]}"





  end
end
