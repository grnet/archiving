require 'spec_helper'

describe Admin::PoolsController do
  it 'routes GET /admin/pools' do
    expect(get('/admin/pools')).to route_to(controller: 'admin/pools', action: 'index')
  end

  it 'routes GET /admin/pools/new' do
    expect(get('/admin/pools/new')).
      to route_to(controller: 'admin/pools', action: 'new')
  end

  it 'routes GET /admin/pools/1' do
    expect(get('/admin/pools/1')).
      to route_to(controller: 'admin/pools', action: 'show', id: '1')
  end

  it 'routes GET /admin/pools/1/edit' do
    expect(get('/admin/pools/1/edit')).
      to route_to(controller: 'admin/pools', action: 'edit', id: '1')
  end

  it 'routes POST /admin/pools' do
    expect(post('/admin/pools')).
      to route_to(controller: 'admin/pools', action: 'create')
  end

  it 'routes PATCH /admin/pools/1' do
    expect(patch('/admin/pools/1')).
      to route_to(controller: 'admin/pools', action: 'update', id: '1')
  end
end
