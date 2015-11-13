require 'spec_helper'

describe ClientsController do
  let(:host) { FactoryGirl.create(:host, :with_client) }
  let(:user) { FactoryGirl.create(:user) }

  before do
    allow_any_instance_of(ClientsController).to receive(:current_user) { user }
    host.users << user
  end

  describe '#index' do
    it 'fetches the host' do
      get root_path
      expect(response.body).to match(host.name)
    end
  end
end
