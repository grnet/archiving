require 'spec_helper'

describe FilesetsController do
  it 'routes GET /hosts/:host_id/filesets/new' do
    expect(get('/hosts/1/filesets/new')).
      to route_to(controller: 'filesets', action: 'new', host_id: '1')
  end

  it 'routes POST /hosts/:host_id/filesets' do
    expect(post('/hosts/1/filesets')).
      to route_to(controller: 'filesets', action: 'create', host_id: '1')
  end

  it 'routes GET /hosts/:host_id/filesets/:id' do
    expect(get('/hosts/1/filesets/2')).
      to route_to(controller: 'filesets', action: 'show', host_id: '1', id: '2')
  end

  it 'routes DELETE /hosts/:host_id/filesets/:id' do
    expect(delete('/hosts/1/filesets/2')).
      to route_to(controller: 'filesets', action: 'destroy', host_id: '1', id: '2')
  end
end
