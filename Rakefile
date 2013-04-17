require 'rake/testtask'

task :test do
  Rake::TestTask.new do |t|
    t.pattern = "spec/**/*_spec.rb"
  end
end

namespace :test do
  desc "Run all tests (rake test will do this be default)"
  task :all do
    Rake::TestTask.new("all") do |t|
      t.pattern = "spec/**/*_spec.rb"
    end
    task("all").execute
  end

  Dir.foreach("spec") do |dirname|
    if File.directory?(File.join("spec", dirname))
      desc "Run #{dirname} tests"
      task dirname do
        test_task = Rake::TestTask.new("#{dirname}tests") do |t|
          t.test_files = Dir.glob(File.join("spec", dirname, "**", "*_spec.rb"))
        end
        task("#{dirname}tests").execute
      end
    end
  end

  desc "Run single file"
  task :file, :file do |task, args|
    test_task = Rake::TestTask.new("unittests") do |t|
      if args.file
        file = args.file
        unless file.start_with? "spec/"
          file = "spec/#{args.file}"
        end
        t.pattern = file
        puts "Testing #{file}"
      else
        t.pattern = "spec/models/*_test.rb"
      end
    end
    task("unittests").execute
  end
end
