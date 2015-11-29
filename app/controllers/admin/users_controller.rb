class Admin::UsersController < Admin::BaseController
  # GET /admin/users
  def index
    @baculized_host_names = Hash.new { |h, k| h[k] = [] }
    @non_baculized_host_names = Hash.new { |h, k| h[k] = [] }
    @unverified_host_names = Hash.new { |h, k| h[k] = [] }

    @users = User.all.includes(:hosts)
    @users.each do |user|
      user.hosts.each do |host|
        if host.deployed? || host.updated? || host.dispatched? || host.for_removal?
          @baculized_host_names[user.id] << host.name
        else
          @non_baculized_host_names[user.id] << host.name
          @unverified_host_names[user.id] << host.name if !host.verified?
        end
      end
    end
  end
end
