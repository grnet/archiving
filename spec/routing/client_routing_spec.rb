require 'spec_helper'

describe ClientsController do
  it 'routes /clients' do
    expect(get('/clients')).to route_to(controller: 'clients', action: 'index')
  end

  it 'routes /clients' do
    expect(post('/clients')).to route_to(controller: 'clients', action: 'index')
  end

  it 'routes GET /' do
    expect(get('/')).to route_to(controller: 'clients', action: 'index')
  end

  it 'routes GET /clients/1' do
    expect(get('/clients/1')).to route_to(controller: 'clients', action: 'show', id: '1')
  end

  it 'routes GET /clients/1/stats' do
    expect(get('/clients/1/stats')).
      to route_to(controller: 'clients', action: 'stats', id: '1')
  end

  it 'routes POST /clients/1/stats' do
    expect(post('/clients/1/stats')).
      to route_to(controller: 'clients', action: 'stats', id: '1')
  end

  it 'routes GET /clients/1/logs' do
    expect(get('/clients/1/logs')).
      to route_to(controller: 'clients', action: 'logs', id: '1')
  end

  it 'routes GET /clients/1/jobs' do
    expect(get('/clients/1/jobs')).
      to route_to(controller: 'clients', action: 'jobs', id: '1')
  end
end

