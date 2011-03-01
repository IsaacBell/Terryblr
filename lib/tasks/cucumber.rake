# IMPORTANT: This file is generated by cucumber-rails - edit at your own peril.
# It is recommended to regenerate this file in the future when you upgrade to a 
# newer version of cucumber-rails. Consider adding your own code to a new file 
# instead of editing this one. Cucumber will automatically load all features/**/*.rb
# files.


unless ARGV.any? {|a| a =~ /^gems/} # Don't load anything when running the gems:* tasks

begin
  require 'cucumber/rake/task'

  namespace :cucumber do
    Cucumber::Rake::Task.new({:ok => 'dummy:db:test:prepare'}, 'Run features that should pass') do |t|
      t.binary = nil # If nil, the gem's binary is used.
      t.fork = false # You may get faster startup if you set this to false
      t.profile = 'default'
    end

    Cucumber::Rake::Task.new({:html}, 'Run all the features, output html') do |t|
      mkdir_p 'tmp/cucumber' unless File.exists? 'tmp/cucumber'
      t.binary = nil # If nil, the gem's binary is used.
      t.fork = false # You may get faster startup if you set this to false
      t.profile = 'html'
      # t.cucumber_opts = '--format html --out tmp/cucumber/index.html'
    end

    Cucumber::Rake::Task.new({:wip => 'dummy:db:test:prepare'}, 'Run features that are being worked on') do |t|
      t.binary = nil
      t.fork = true # You may get faster startup if you set this to false
      t.profile = 'wip'
    end

    Cucumber::Rake::Task.new({:rerun => 'dummy:db:test:prepare'}, 'Record failing features and run only them if any exist') do |t|
      t.binary = nil
      t.fork = true # You may get faster startup if you set this to false
      t.profile = 'rerun'
    end

    desc 'Run all features'
    task :all => [:ok, :wip]
  end
  desc 'Alias for cucumber:ok'
  task :cucumber => 'cucumber:ok'

  task :default => :cucumber

  task :features => :cucumber do
    STDERR.puts "*** The 'features' task is deprecated. See rake -T cucumber ***"
  end
rescue LoadError
  desc 'cucumber rake task not available (cucumber not installed)'
  task :cucumber do
    abort 'Cucumber rake task is not available. Be sure to install cucumber as a gem or plugin'
  end
end

end
