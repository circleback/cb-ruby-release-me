require 'statsd'

module ReleaseMe
  module Services
    module Publishers

      class DatadogPublisher

        def initialize

          @client = Statsd.new('localhost', 8125)

        end

        def publish_release(release_version, system_name, env)

          @client.event(release_version, "#{system_name} #{release_version} is deployed to #{env}", :build_env => env, :build_ver => release_version, :build_system => system_name)

        end


      end

    end
  end
end
