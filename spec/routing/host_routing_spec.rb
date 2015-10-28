require 'spec_helper'

describe HostsController do
  it 'routes GET /hosts/new' do
    expect(get('/hosts/new')).to route_to(controller: 'hosts', action: 'new')
  end

  it 'routes POST /hosts' do
    expect(post('/hosts')).to route_to(controller: 'hosts', action: 'create')
  end

  it 'routes GET /hosts/1' do
    expect(get('/hosts/1')).to route_to(controller: 'hosts', action: 'show', id: '1')
  end

  it 'routes GET /hosts/1/edit' do
    expect(get('/hosts/1/edit')).to route_to(controller: 'hosts', action: 'edit', id: '1')
  end

  it 'routes PUT /hosts/1' do
    expect(put('/hosts/1')).to route_to(controller: 'hosts', action: 'update', id: '1')
  end

  it 'routes DELETE /hosts/1' do
    expect(delete('/hosts/1')).to route_to(controller: 'hosts', action: 'destroy', id: '1')
  end
end
