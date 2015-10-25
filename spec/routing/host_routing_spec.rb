require 'spec_helper'

describe HostsController do
  it 'routes GET /hosts/new' do
    expect(get('/hosts/new')).to route_to( { controller: 'hosts', action: 'new' })
  end

  it 'routes POST /hosts' do
    expect(post('/hosts')).to route_to( { controller: 'hosts', action: 'create' })
  end
end
