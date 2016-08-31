require 'httparty'

module ReleaseMe
  module Services
    module Publishers

      class DatadogPublisher

        def initialize(api_key)
          @api_key = api_key
          @api_base_url = "https://app.datadoghq.com/api/v1/events"
        end

        def publish_release(release_version, system_name, env)


          publish_event(release_version,"#{system_name} #{release_version} is deployed to #{env}",[system_name,env])

        end

        def publish_event(title,description,tags = :no_tags)

          event_body = {:api_key => @api_key,
                        :msg_title => title,
                        :msg_text => description
          }

          unless tags == :no_tags
            event_body[:tags] = tags
          end

          HTTParty.post(@api_base_url,:body => event_body.to_json, :headers => {'Content-Type' => 'application/json'})

        end


      end

    end
  end
end
