source 'https://rubygems.org'

platforms :rbx do
  gem "json"
  gem "racc"
  gem "rubysl"
end

group :test do
  gem "rake"              # rakefile
  gem "minitest", "4.7.0" # test framework (specified here for prior rubies)
  gem "ansi"              # minitest colors
  gem "turn"              # minitest output
  gem "mocha"             # stubs

  gem "awesome_print"
  gem "rack-test"
end

# Specify your gem's dependencies in rack-nelumba.gemspec
gemspec

gem "nelumba",         :git => "git://github.com/hotsh/nelumba.git"
gem "nelumba-mongodb", :git => "git://github.com/hotsh/nelumba-mongodb.git"
gem "redfinger",     :git => "git://github.com/hotsh/redfinger.git"
