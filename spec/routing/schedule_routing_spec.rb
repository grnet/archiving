require 'spec_helper'

describe SchedulesController do
  it 'routes GET /schedules/new' do
    expect(get('/schedules/new')).to route_to( { controller: 'schedules', action: 'new'})
  end

  it 'routes POST /schedules' do
    expect(post('/schedules')).to route_to( { controller: 'schedules', action: 'create'})
  end

  it 'routes GET /schedules/1' do
    expect(get('/schedules/1')).to route_to( { controller: 'schedules', action: 'show', id: '1' })
  end

  it 'routes GET /schedules/1/edit' do
    expect(get('/schedules/1/edit')).to route_to( { controller: 'schedules', action: 'edit', id: '1' })
  end

  it 'routes PUT /schedules/1' do
    expect(put('/schedules/1')).to route_to( { controller: 'schedules', action: 'update', id: '1' })
  end

  it 'routes DELETE /schedules/1' do
    expect(delete('/schedules/1')).to route_to( { controller: 'schedules', action: 'destroy', id: '1' })
  end
end
