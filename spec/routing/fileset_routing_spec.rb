require 'spec_helper'

describe FilesetsController do
  it 'routes GET /filesets/new' do
    expect(get('/filesets/new')).to route_to( { controller: 'filesets', action: 'new'})
  end

  it 'routes POST /filesets' do
    expect(post('/filesets')).to route_to( { controller: 'filesets', action: 'create'})
  end

  it 'routes GET /filesets/1' do
    expect(get('/filesets/1')).
      to route_to( { controller: 'filesets', action: 'show', id: '1' })
  end

  it 'routes DELETE /filesets/1' do
    expect(delete('/filesets/1')).
      to route_to( { controller: 'filesets', action: 'destroy', id: '1' })
  end
end
