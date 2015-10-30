require 'spec_helper'

describe HostsController do
  it 'routes GET /jobs/new' do
    expect(get('/jobs/new')).to route_to( { controller: 'jobs', action: 'new' })
  end

  it 'routes POST /jobs' do
    expect(post('/jobs')).to route_to( { controller: 'jobs', action: 'create' })
  end

  it 'routes GET /jobs/1' do
    expect(get('/jobs/1')).to route_to( { controller: 'jobs', action: 'show', id: '1' })
  end

  it 'routes GET /jobs/1/edit' do
    expect(get('/jobs/1/edit')).to route_to( { controller: 'jobs', action: 'edit', id: '1' })
  end

  it 'routes PUT /jobs/1' do
    expect(put('/jobs/1')).to route_to( { controller: 'jobs', action: 'update', id: '1' })
  end

  it 'routes DELETE /jobs/1' do
    expect(delete('/jobs/1')).to route_to( { controller: 'jobs', action: 'destroy', id: '1' })
  end
end
