require 'spec_helper'

describe ClientsController do
  it 'routes /clients' do
    expect(get('/clients')).to route_to(controller: 'clients', action: 'index')
  end

  it 'routes GET /' do
    expect(get('/')).to route_to(controller: 'clients', action: 'index')
  end

  it 'routes GET /clients/1' do
    expect(get('/clients/1')).to route_to(controller: 'clients', action: 'show', id: '1')
  end
end

