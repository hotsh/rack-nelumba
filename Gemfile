source 'https://rubygems.org'

# Specify your gem's dependencies in ostatus.gemspec
gemspec

group :test do
  gem "rake"              # rakefile
  gem "minitest", "4.7.0" # test framework (specified here for prior rubies)
  gem "ansi"              # minitest colors
  gem "turn"              # minitest output
  gem "mocha"             # stubs

  gem "awesome_print"
  gem "rack-test"
end

platforms :rbx do
  gem "json"
  gem "racc"
  gem "rubysl"
end

gem "lotus",         :git => "git://github.com/hotsh/lotus.git"
gem "lotus-mongodb", :git => "git://github.com/hotsh/lotus-mongodb.git"
gem "redfinger",     :git => "git://github.com/hotsh/redfinger.git"
