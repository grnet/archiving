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

      it 'redirects to a new job form' do
        post :create, params
        expect(response).to redirect_to(new_host_job_path(host, fileset_id: Fileset.last.id))
      end

      context 'and an existing job' do
        let(:job) { FactoryGirl.create(:job_template, host: host) }

        it 'redirects to the job\'s edit form' do
          post :create, params.merge(job_id: job.id)
          expect(response).
            to redirect_to(edit_host_job_path(host, job, fileset_id: Fileset.last.id))
        end
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
