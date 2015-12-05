require 'spec_helper'

describe Admin::ClientsController do
  it 'routes GET /admin/clients' do
    expect(get('/admin/clients')).to route_to(controller: 'admin/clients', action: 'index')
  end

  it 'routes GET /admin/clients/1' do
    expect(get('/admin/clients/1')).
      to route_to(controller: 'admin/clients', action: 'show', id: '1')
  end

  it 'routes GET /admin/clients/1/stats' do
    expect(get('/admin/clients/1/stats')).
      to route_to(controller: 'admin/clients', action: 'stats', id: '1')
  end

  it 'routes POST /admin/clients/1/stats' do
    expect(post('/admin/clients/1/stats')).
      to route_to(controller: 'admin/clients', action: 'stats', id: '1')
  end

  it 'routes GET /admin/clients/1/logs' do
    expect(get('/admin/clients/1/logs')).
      to route_to(controller: 'admin/clients', action: 'logs', id: '1')
  end

  it 'routes GET /admin/clients/1/jobs' do
    expect(get('/admin/clients/1/jobs')).
      to route_to(controller: 'admin/clients', action: 'jobs', id: '1')
  end

  it 'routes GET /admin/clients/1/configuration' do
    expect(get('/admin/clients/1/configuration')).
      to route_to(controller: 'admin/clients', action: 'configuration', id: '1')
  end

  it 'routes POST /admin/clients/1/disable' do
    expect(post('/admin/clients/1/disable')).
      to route_to(controller: 'admin/clients', action: 'disable', id: '1')
  end

  it 'routes DELETE /admin/clients/1/revoke' do
    expect(delete('/admin/clients/1/revoke')).
      to route_to(controller: 'admin/clients', action: 'revoke', id: '1')
  end
end
