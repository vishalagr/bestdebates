# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end
#set :environment, :development
# Learn more: http://github.com/javan/whenever
every 5.minutes do
  rake "thinking_sphinx:rebuild"
end

every 1.day, :at => '3:50 am' do
  runner "Argument.argument_daily_digest"
end

every 1.day, :at => '3:50 am' do
  runner "Debate.debate_daily_digest"
end