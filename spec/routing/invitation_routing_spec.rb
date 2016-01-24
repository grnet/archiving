require 'spec_helper'

describe InvitationsController do
  it 'routes POST /invitations' do
    expect(post('/invitations')).to route_to(controller: 'invitations', action: 'create')
  end
end

