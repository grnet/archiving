require 'spec_helper'

describe Admin::UsersController do
  it 'routes GET /admin/users' do
    expect(get('/admin/users')).to route_to(controller: 'admin/users', action: 'index')
  end

  it 'routes PATCH /admin/users/1/ban' do
    expect(patch('/admin/users/1/ban')).
      to route_to(controller: 'admin/users', action: 'ban', id: '1')
  end

  it 'routes PATCH /admin/users/1/unban' do
    expect(patch('/admin/users/1/unban')).
      to route_to(controller: 'admin/users', action: 'unban', id: '1')
  end
end
