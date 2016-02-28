require 'spec_helper'

describe Admin::FaqsController do
  it 'routes GET /admin/faqs' do
    expect(get('/admin/faqs')).to route_to(controller: 'admin/faqs', action: 'index')
  end

  it 'routes GET /admin/faqs/new' do
    expect(get('/admin/faqs/new')).
      to route_to(controller: 'admin/faqs', action: 'new')
  end

  it 'routes GET /admin/faqs/1' do
    expect(get('/admin/faqs/1')).
      to route_to(controller: 'admin/faqs', action: 'show', id: '1')
  end

  it 'routes GET /admin/faqs/1/edit' do
    expect(get('/admin/faqs/1/edit')).
      to route_to(controller: 'admin/faqs', action: 'edit', id: '1')
  end

  it 'routes PUT /admin/faqs/1' do
    expect(put('/admin/faqs/1')).
      to route_to(controller: 'admin/faqs', action: 'update', id: '1')
  end

  it 'routes POST /admin/faqs' do
    expect(post('/admin/faqs')).
      to route_to(controller: 'admin/faqs', action: 'create')
  end

  it 'routes DELETE /admin/faqs/1' do
    expect(delete('/admin/faqs/1')).
      to route_to(controller: 'admin/faqs', action: 'destroy', id: '1')
  end
end
