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
          expect(config.issue_tracker).to eq :jira
          expect(config.source_manager).to eq :git
          expect(config.publishers).to contain_exactly(:hipchat,:datadog)
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

      context 'with key starting with publishers.' do
        let(:opts) do
          { 'publishers.hipchat.api_token' => '12345', 'publishers.hipchat.chat_room' => 'chat room',
            'publisher_system_name' => 'System name to deploy',
            'publishers.datadog.api_key' => '67890'
          }
        end

        subject(:publishers_config) { config.publishers_config }

        it 'is a hash'do
          expect(publishers_config).to be_a(Hash)
        end

        it 'has key of :hipchat with value of hash' do
          expect(publishers_config.has_key?(:hipchat)).to be true
          expect(publishers_config[:hipchat]).to be_a Hash
        end

        it 'has hash with :api_token key and value 12345' do
          expect(publishers_config[:hipchat][:api_token]).to eq '12345'
        end

        it 'has hash with :chat_room key and value chat room' do
          expect(publishers_config[:hipchat][:chat_room]).to eq 'chat room'
        end

        it 'has top level config of .publisher_system_name' do
          expect(config.publisher_system_name).to eq 'System name to deploy'
        end

        it 'has key of :datadog with value of hash' do
          expect(publishers_config.has_key?(:datadog)).to be true
          expect(publishers_config[:datadog]).to be_a Hash
        end

        it 'has hash with :api_key key and value 67890' do
          expect(publishers_config[:datadog][:api_key]).to eq '67890'
        end

      end


      context 'with key starting with deployment_manager.options' do
        let(:opts) do
          { 'publishers.hipchat.api_token' => '12345', 'publishers.hipchat.chat_room' => 'chat room',
            'publisher_system_name' => 'System name to deploy',
            'deployment_manager.options' => {'option_key' => 'option_value', 'another_option' => 'value_2' }
          }
        end

        subject(:deployment_options) { config.deployment_manager_options }

        it 'is a hash'do
          expect(deployment_options).to be_a(Hash)
        end

        it 'has key of option_key with value of hash' do
          expect(deployment_options.has_key?(:option_key.to_s)).to be true
          expect(deployment_options[:option_key.to_s]).to eq 'option_value'
        end

        it 'has hash with another_option key and value value_2' do
          expect(deployment_options[:another_option.to_s]).to eq 'value_2'
        end


      end

    end




  end

end