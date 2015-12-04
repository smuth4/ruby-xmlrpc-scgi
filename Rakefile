require 'bundler/gem_tasks'

task default: %w(rubocop rspec)

desc 'Run rubocop'
task :rubocop do
  sh 'rubocop'
end

desc 'Run RSpec'
task :rspec do
  sh 'bundle exec rspec spec'
end
