require 'spec_helper'

describe Admin::PoolsController do
  it 'routes GET /admin/pools' do
    expect(get('/admin/pools')).to route_to(controller: 'admin/pools', action: 'index')
  end

  it 'routes GET /admin/pools/new' do
    expect(get('/admin/pools/new')).
      to route_to(controller: 'admin/pools', action: 'new')
  end

  it 'routes POST /admin/pools' do
    expect(post('/admin/pools')).
      to route_to(controller: 'admin/pools', action: 'create')
  end
end
