require 'dotenv/tasks'

namespace :db do
  desc "creates and migrates with env vars"
  task create_migrate: :dotenv do
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke
  end

end
