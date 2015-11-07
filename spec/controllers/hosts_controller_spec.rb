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

  describe 'PATCH #update' do
    let!(:host) { FactoryGirl.create(:host) }

    context 'with valid params' do
      let(:params) do
        {
          id: host.id,
          host: { port: 9999, password: 'wrong_pass' }
        }
      end

      it 'updates the host' do
        expect { patch :update, params }.
          to change { [host.reload.port, host.reload.password] }.
          to([9999, 'wrong_pass'])
      end

      it 'redirects to host_show' do
        patch :update, params
        expect(response).to redirect_to(host_path(host))
      end
    end

    context 'with fqdn in params' do
      let(:params) do
        {
          id: host.id,
          host: { fqdn: 'another.host.gr' }
        }
      end

      it 'does not update the host' do
        expect { patch :update, params }.
          to_not change { host.reload.fqdn }
      end

      it 'renders the edit page' do
        patch :update, params
        expect(response).to render_template(:edit)
      end
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

  describe 'POST #submit_config' do
    let(:host) { FactoryGirl.create(:host, :configured) }
    let(:params) { { id: host.id } }

    it 'redirects to root' do
      post :submit_config, params
      expect(response).to redirect_to(host_path(host))
    end

    it 'calls submit_config_to_bacula on host' do
      Host.any_instance.should_receive(:dispatch_to_bacula)
      post :submit_config, params
    end
  end
end
