require_relative '../issue_trackers/jira_tracker'

module ReleaseMe
  module Services
    module Publishers

      class JiraPublisher

        def initialize(jira_tracker)
          @jira_tracker = jira_tracker
        end

        def publish_release(release_version, env, issues = [])

          if env == 'production'
            issues.each do |issue|
              @jira_tracker.add_deployment_comment(issue.id,release_version)
            end
          end

        end


      end

    end
  end
end
