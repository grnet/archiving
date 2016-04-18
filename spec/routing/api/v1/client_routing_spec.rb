require 'spec_helper'

describe Api::V1::ClientsController do
  it 'routes GET /api/clients' do
    expect(get('/api/clients')).
      to route_to(controller: 'api/v1/clients', action: 'index', format: :json)
  end

  it 'routes GET /api/clients/:id' do
    expect(get('/api/clients/1')).
      to route_to(controller: 'api/v1/clients', action: 'show', id: '1', format: :json)
  end
  it 'routes POST /api/clients/:id/backup' do
    expect(post('/api/clients/1/backup')).
      to route_to(controller: 'api/v1/clients', action: 'backup', id: '1', format: :json)
  end
  it 'routes POST /api/clients/:id/restore' do
    expect(post('/api/clients/1/restore')).
      to route_to(controller: 'api/v1/clients', action: 'restore', id: '1', format: :json)
  end
end
