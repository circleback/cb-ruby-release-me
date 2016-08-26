
module ReleaseMe
  module Services
    module DeploymentManagers

      class TowerManager

        def initialize(tower_api_url, tower_user, tower_password)

          username = tower_user
          password = tower_password

          options  = {:username => username, :password => password, :site => tower_api_url, :context_path => '', :auth_type => :basic}

          @options = options

        end

        def start_job_from_template(job_template_id, extra_vars_hash = :not_given)

          current_status = "unknown"

          outer_extra_vars = ''
          extra_vars_string = ''

          username = @options[:username]
          pwd = @options[:password]
          tower_server_url = @options[:site]


          default_opts = {}

          default_opts.merge!(extra_vars_hash) unless extra_vars_hash == :not_given

          unless extra_vars_hash == :not_given

            extra_vars_string += '"{'
            extra_vars_hash.each_pair do |k,v|
              extra_vars_string += '\"'+ k + '\":\"' + v + '\",'
            end

            extra_vars_string.chomp!(',')

            extra_vars_string += '}"'

            outer_extra_vars = '{"extra_vars": ' + extra_vars_string  + '}'

          end

          job_launch_response_string =`curl -f -k -H 'Content-Type: application/json' -XPOST -d '#{outer_extra_vars}'  --user #{username}:#{pwd} #{tower_server_url}/job_templates/#{job_template_id}/launch/` ;  result=$?.success?

          if result

            job_launch_response = JSON.parse(job_launch_response_string)

            if  job_launch_response.has_key?("id")
              job_id = job_launch_response['id']
              job_stdout = `curl -f -k -H 'Content-Type: application/json' -XGET  --user #{username}:#{pwd} #{tower_server_url}/jobs/#{job_id}/stdout/?format=ansi` ;  result=$?.success?

              puts job_stdout
              puts "check status"

              current_status = "waiting"

              while current_status != "successful" do

                job_response_string = `curl -f -k -H 'Content-Type: application/json' -XGET  --user #{username}:#{pwd} #{tower_server_url}/jobs/#{job_id}/` ;  result=$?.success?

                if result
                  job_response = JSON.parse(job_response_string)
                  current_status = job_response["status"]

                  puts "from #{tower_server_url}jobs/#{job_id} - JOB STATUS IS #{current_status}"
                  unless current_status == "successful"
                    20.times do |x|
                      print "."
                      if current_status == "waiting" || current_status == "pending"
                        sleep 3
                      else
                        sleep 1
                      end
                    end
                  end

                  puts ""
                else
                  puts "error calling ansible tower server!"
                  break

                end

              end
            end
          end

          puts "final job status is set as #{current_status}"

          current_status

        end



      end



    end
  end
end
