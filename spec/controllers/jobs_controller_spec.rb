require 'spec_helper'

describe JobsController do
  let!(:host) { FactoryGirl.create(:host) }

  describe 'GET #new' do
    before { get :new, host_id: host.id }

    it 'initializes a job' do
      expect(assigns(:job)).to be
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
          job_template: FactoryGirl.build(:job_template).attributes.symbolize_keys.
            slice(:name, :schedule_id, :fileset_id).merge(job_type: :backup)
        }
      end

      it 'creates the job' do
        expect { post :create, params }.
          to change { JobTemplate.count }.by(1)
      end

      it 'redirects to root' do
        post :create, params
        expect(response).to redirect_to(host_path(host))
      end
    end

    context 'with invalid params' do
      let(:params) do
        {
          host_id: host.id,
          job_template: FactoryGirl.build(:job_template).attributes.symbolize_keys.
            slice(:name, :fileset_id)
        }
      end

      it 'initializes a job with errors' do
        post :create, params
        expect(assigns(:job)).to be
      end

      it 'does not create the job' do
        expect { post :create, params }.
          to_not change { JobTemplate.count }
      end

      it 'renders :new' do
        post :create, params
        expect(response).to render_template(:new)
      end
    end
  end
end
