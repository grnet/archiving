namespace :db do
  desc 'Create schema migrations on local database'
  task :generate_migrations => :environment do
    ActiveRecord::Base.establish_connection(Archiving::settings[:local_db]).
      connection.execute("CREATE TABLE `schema_migrations` (`version` varchar(255) NOT NULL, UNIQUE KEY `unique_schema_migrations` (`version`));")
  end
end
