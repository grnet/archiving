require 'spec_helper'

describe FilesetsController do
  let(:host) { FactoryGirl.create(:host) }

  describe 'GET #new' do
    before { get :new, host_id: host.id }

    it 'initializes a fileset' do
      expect(assigns(:fileset)).to be
    end

    it 'sets host the fileset\'s host' do
      expect(assigns(:fileset).host).to eq(host)
    end

    it 'renders' do
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      let(:params) do
        {
          host_id: host.id,
          fileset: {
            name: FactoryGirl.build(:fileset).name,
            exclude_directions: ['/proc', '/tmp'],
            include_files: ['/home', '/media']
          }
        }
      end

      it 'creates the fileset' do
        expect { post :create, params }.
          to change { host.filesets(true).count }.by(1)
      end

      it 'redirects to host' do
        post :create, params
        expect(response).to redirect_to(host_path(host))
      end
    end

    context 'with invalid params' do
      let(:params) do
        {
          host_id: host.id,
          fileset: { invalid: :foo }
        }
      end

      it 'initializes a fileset with errors' do
        post :create, params
        expect(assigns(:fileset)).to be
      end

      it 'sets the host' do
        post :create, params
        expect(assigns(:fileset).host).to eq(host)
      end

      it 'does not create the fileset' do
        expect { post :create, params }.
          to_not change { Fileset.count }
      end

      it 'renders :new' do
        post :create, params
        expect(response).to render_template(:new)
      end
    end
  end
end
