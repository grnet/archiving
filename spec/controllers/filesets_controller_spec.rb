require 'spec_helper'

describe FilesetsController do
  describe 'GET #new' do
    before { get :new }

    it 'initializes a fileset' do
      expect(assigns(:fileset)).to be
    end

    it 'renders' do
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      let(:params) do
        {
          fileset: { name: FactoryGirl.build(:fileset).name,
                     exclude_directions: ['/proc', '/tmp'],
                     include_files: ['/home', '/media']
        }
        }
      end

      it 'creates the fileset' do
        expect { post :create, params }.
          to change { Fileset.count }.by(1)
      end

      it 'redirects to root' do
        post :create, params
        expect(response).to redirect_to(root_path)
      end
    end

    context 'with invalid params' do
      let(:params) { { fileset: { invalid: :foo } } }

      it 'initializes a fileset with errors' do
        post :create, params
        expect(assigns(:fileset)).to be
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
