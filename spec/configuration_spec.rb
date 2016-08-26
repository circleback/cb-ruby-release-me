require 'spec_helper'

describe ReleaseMe::Configuration do

  describe 'initialize' do
    let(:opts){ {} }
    let(:args_splat){ nil }
    subject(:config) do
      ReleaseMe::Configuration.new(opts, *args_splat)
    end

    context 'with no parameters' do
      subject(:config) do
        ReleaseMe::Configuration.new
      end
      it 'is Configuration with defaults loaded' do
        expect(config.publisher_api_token).to eq :publisher_api_token_not_set
          expect(config.issue_tracker).to eq :jira
          expect(config.source_manager).to eq :git
      end


    end

    context 'with options_hash provided' do
      let(:opts){ {"environment_to_deploy" => "qa"} }
      subject(:config) do
        ReleaseMe::Configuration.new(opts)
      end
      it 'is Configuration with defaults plus keys provided as override' do
        expect(config.environment_to_deploy).to eq "qa"
      end

      context 'and key=value, rake args style provided' do
        let(:api_token){ 'my_api_token'}
        let(:args_splat){  "publisher_api_token=#{api_token}"  }
        subject(:config) do
          ReleaseMe::Configuration.new(opts, *args_splat)
        end
        it 'is Configuration with rake args provided' do
          expect(config.publisher_api_token).to eq(api_token)
        end

        context 'with mutliple key=value args provided' do
          let(:args_splat){  ["publisher_api_token=#{api_token}","version_increase=major"] }
          subject(:config) do
            ReleaseMe::Configuration.new(opts, *args_splat)
          end
          it 'is Configuration with .publisher_api_token = my_api_token' do
            expect(config.publisher_api_token).to eq(api_token)
          end
          it 'is Configuration with .version_increase = major' do
            expect(config.version_increase).to eq('major')
          end
        end

        context 'with mutliple key=value args provided conflicting with hash_values' do
          let(:args_splat){  ["publisher_api_token=#{api_token}","version_increase=major"] }
          let(:opts){ {"version_increase" => "minor"} }
          subject(:config) do
            ReleaseMe::Configuration.new(opts, *args_splat)
          end
          it 'is Configuration with .publisher_api_token = my_api_token' do
            expect(config.publisher_api_token).to eq(api_token)
          end
          it 'is Configuration with .version_increase = major' do
            expect(config.version_increase).to eq('major')
          end

        end

        context 'with environment_to_deploy is production version_increase defaults to none ' do
          let(:args_splat){  ["publisher_api_token=#{api_token}"] }
          let(:opts){ {"environment_to_deploy" => "production"} }
          subject(:config) do
            ReleaseMe::Configuration.new(opts, *args_splat)
          end
          it 'is Configuration with .publisher_api_token = my_api_token' do
            expect(config.publisher_api_token).to eq(api_token)
          end
          it 'is Configuration with .version_increase = none' do
            expect(config.version_increase).to eq('none')
          end
        end

        context 'with environment_to_deploy is qa version_increase defaults to patch ' do
          let(:args_splat){  ["publisher_api_token=#{api_token}"] }
          let(:opts){ {"environment_to_deploy" => "qa"} }
          subject(:config) do
            ReleaseMe::Configuration.new(opts, *args_splat)
          end
          it 'is Configuration with .publisher_api_token = my_api_token' do
            expect(config.publisher_api_token).to eq(api_token)
          end
          it 'is Configuration with .version_increase = patch' do
            expect(config.version_increase).to eq('patch')
          end
        end


        context 'with environment_to_deploy is qa version_increase is passed to minor ' do
          let(:args_splat){  ["publisher_api_token=#{api_token}","version_increase=minor"] }
          let(:opts){ {"environment_to_deploy" => "qa"} }
          subject(:config) do
            ReleaseMe::Configuration.new(opts, *args_splat)
          end
          it 'is Configuration with .publisher_api_token = my_api_token' do
            expect(config.publisher_api_token).to eq(api_token)
          end
          it 'is Configuration with .version_increase = minor' do
            expect(config.version_increase).to eq('minor')
          end
          it 'is Configuration with .environment_to_deploy = qa' do
            expect(config.environment_to_deploy).to eq('qa')
          end
        end


      end


    end




  end

end