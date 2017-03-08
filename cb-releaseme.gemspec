
Gem::Specification.new do |s|
  s.name        = 'cb-releaseme'
  s.license     = 'LICENSE.txt'
  s.version     = '0.1.6'
  s.date        = '2016-08-25'
  s.summary     = 'help coordinate and track releases with deployment'
  s.description = <<-EOS

  EOS
  s.authors     = ['Jay Danielian']
  s.email       = ['info@circleback.com']
  s.files       = `git ls-files lib`.split(/\n/) + %w{ README.md LICENSE.txt }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.homepage    = 'http://github.com/circleback/cb-ruby-release-me'
  s.add_dependency 'git', '~> 1.2.9.1'
  s.add_dependency 'jira-ruby', '~> 0.1.14'
  s.add_dependency 'git-version-bump', '~> 0.14.0'
  s.add_dependency 'hipchat', '~> 1.5'
  s.add_dependency 'dogstatsd-ruby', '~> 1.6.0'
  s.add_dependency 'httparty', '~> 0.14'
  s.add_development_dependency 'rspec', '~> 3.0.0'
  s.add_development_dependency 'guard'
  s.add_development_dependency 'guard-rspec'
  s.require_path = 'lib'
end