require 'spec_helper'

describe HostsController do
  describe 'GET #new' do
    before { get :new }

    it 'initializes a host' do
      expect(assigns(:host)).to be
    end

    it 'renders' do
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      let(:params) do
        {
          host: FactoryGirl.build(:host).attributes.symbolize_keys.
            slice(:password, :fqdn, :port)
        }
      end

      it 'creates the host' do
        expect { post :create, params }.
          to change { Host.count }.by(1)
      end

      it 'redirects to root' do
        post :create, params
        expect(response).to redirect_to(host_path(Host.last))
      end
    end

    context 'with invalid params' do
      let(:params) do
        {
          host: FactoryGirl.build(:host).attributes.symbolize_keys.
            slice(:fqdn, :port)
        }
      end

      before { post :create, params }

      it 'initializes a host with errors' do
        expect(assigns(:host)).to be
      end

      it 'renders :new' do
        expect(response).to render_template(:new)
      end
    end
  end
end
