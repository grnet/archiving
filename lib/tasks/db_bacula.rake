task spec: ["bacula:db:test:prepare"]

namespace :bacula do
  namespace :db do |ns|
    task :drop do
      Rake::Task["db:drop"].invoke
    end

    task :create do
      Rake::Task["db:create"].invoke
    end

    task :setup do
      Rake::Task["db:setup"].invoke
    end

    task :migrate do
      Rake::Task["db:migrate"].invoke
    end

    task :rollback do
      Rake::Task["db:rollback"].invoke
    end

    task :seed do
      Rake::Task["db:seed"].invoke
    end

    task :version do
      Rake::Task["db:version"].invoke
    end

    namespace :schema do
      task :load do
        Rake::Task["db:schema:load"].invoke
      end

      task :dump do
        Rake::Task["db:schema:dump"].invoke
      end
    end

    namespace :test do
      task :prepare do
        Rake::Task["db:test:prepare"].invoke
      end
    end

    # append and prepend proper tasks to all the tasks defined here above
    ns.tasks.each do |task|
      task.enhance ["bacula:set_custom_config"] do
        Rake::Task["bacula:revert_to_original_config"].invoke
      end
    end
  end

  task :set_custom_config do
    ENV['SCHEMA'] ||= 'db/schema.rb'
    # save current vars
    @original_config = {
      env_schema: ENV['SCHEMA'],
      config: Rails.application.config.dup
    }

    # set config variables for custom database
    ENV['SCHEMA'] = "db_bacula/schema.rb"
    Rails.application.config.paths['db'] = ["db_bacula"]
    Rails.application.config.paths['db/migrate'] = ["db_bacula/migrate"]
    Rails.application.config.paths['db/seeds'] = ["db_bacula/seeds.rb"]
    Rails.application.config.paths['config/database'] = ["config/database_bacula.yml"]
  end

  task :revert_to_original_config do
    # reset config variables to original values
    ENV['SCHEMA'] = @original_config[:env_schema]
    Rails.application.config = @original_config[:config]
  end
end
