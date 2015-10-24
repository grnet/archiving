namespace :user do
  desc 'Create a temp user for development reasons'
  task :generate_user => :environment do |t|

    u = User.new
    u.username = 'baas_dev'
    u.email = 'baas_dev@example.com'
    u.user_type = :admin
    u.save
  end
end
