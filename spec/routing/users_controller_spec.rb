require 'spec_helper'

describe UsersController do
  it 'routes GET /users/:id' do
    expect(get('/users/1')).to route_to(controller: 'users', action: 'show', id: '1')
  end

  it 'routes PATCH /users/:id/generate_token' do
    expect(patch('/users/1/generate_token')).
      to route_to(controller: 'users', action: 'generate_token', id: '1')
  end

  it 'generates path for GET /users/:id' do
    expect(get(user_path(1))).to route_to(controller: 'users', action: 'show', id: '1')
  end

  it 'generates path for PATCH /users/:id/generate_token' do
    expect(patch(generate_token_user_path(1))).
      to route_to(controller: 'users', action: 'generate_token', id: '1')
  end
end

