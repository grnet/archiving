require 'spec_helper'

describe HostsController do
  it 'routes GET /hosts/1/jobs/new' do
    expect(get('/hosts/1/jobs/new')).to route_to( { controller: 'jobs', action: 'new', host_id: '1' })
  end

  it 'routes POST /hosts/1/jobs' do
    expect(post('/hosts/1/jobs')).to route_to( { controller: 'jobs', action: 'create', host_id: '1' })
  end

  it 'routes GET /hosts/1/jobs/1' do
    expect(get('/hosts/1/jobs/1')).to route_to( { controller: 'jobs', action: 'show', host_id: '1', id: '1' })
  end

  it 'routes GET /hosts/1/jobs/1/edit' do
    expect(get('/hosts/1/jobs/1/edit')).to route_to( { controller: 'jobs', action: 'edit', host_id: '1', id: '1' })
  end

  it 'routes PUT /hosts/1/jobs/1' do
    expect(put('/hosts/1/jobs/1')).to route_to( { controller: 'jobs', action: 'update', host_id: '1', id: '1' })
  end

  it 'routes DELETE /hosts/1/jobs/1' do
    expect(delete('/hosts/1/jobs/1')).to route_to( { controller: 'jobs', action: 'destroy', host_id: '1', id: '1' })
  end
end
