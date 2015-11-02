require 'spec_helper'

describe SchedulesController do
  it 'routes GET /hosts/:host_id/schedules/new' do
    expect(get('/hosts/1/schedules/new')).
      to route_to(controller: 'schedules', action: 'new', host_id: '1')
  end

  it 'routes POST /hosts/:host_id/schedules' do
    expect(post('/hosts/1/schedules')).
      to route_to(controller: 'schedules', action: 'create', host_id: '1')
  end

  it 'routes GET /hosts/:host_id/schedules/:id' do
    expect(get('/hosts/1/schedules/2')).
      to route_to(controller: 'schedules', action: 'show', host_id: '1', id: '2')
  end

  it 'routes GET /hosts/:host_id/schedules/:id/edit' do
    expect(get('/hosts/1/schedules/2/edit')).
      to route_to(controller: 'schedules', action: 'edit', host_id: '1', id: '2')
  end

  it 'routes PUT /hosts/:host_id/schedules/:id' do
    expect(put('/hosts/1/schedules/2')).
      to route_to(controller: 'schedules', action: 'update', host_id: '1', id: '2')
  end

  it 'routes DELETE /hosts/:host_id/schedules/:id' do
    expect(delete('/hosts/1/schedules/2')).
      to route_to(controller: 'schedules', action: 'destroy', host_id: '1', id: '2')
  end
end
