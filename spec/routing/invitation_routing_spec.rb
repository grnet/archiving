require 'spec_helper'

describe InvitationsController do
  it 'routes POST /invitations' do
    expect(post('/invitations')).to route_to(controller: 'invitations', action: 'create')
  end

  it 'routes GET /invitations/1/abcdef012345689/accept' do
    expect(get('/invitations/1/abcdef012345689/accept')).
      to route_to(controller: 'invitations', action: 'accept',
                  host_id: '1', verification_code: 'abcdef012345689')
  end
end

