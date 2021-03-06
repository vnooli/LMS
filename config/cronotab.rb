# cronotab.rb — Crono configuration file
#
# Here you can specify periodic jobs and schedule.
# You can use ActiveJob's jobs from `app/jobs/`
# You can use any class. The only requirement is that
# class should have a method `perform` without arguments.
#
# class TestJob
#   def perform
#     puts 'Test!'
#   end
# end

require 'rake'
# Be sure to change AppName to your application name!
Rails.application.class.load_tasks

 Crono.perform(BookRemainderJob).every 1.minute

 