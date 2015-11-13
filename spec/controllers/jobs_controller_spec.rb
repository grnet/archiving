require 'spec_helper'

describe JobsController do
  let!(:host) { FactoryGirl.create(:host) }
  let(:user) { FactoryGirl.create(:user) }

  before do
    host.users << user
    controller.stub(:current_user) { user }
  end

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
          job_template: FactoryGirl.build(:job_template, restore_location: '/foo').
            attributes.symbolize_keys.slice(:name, :schedule_id, :fileset_id, :restore_location)
        }
      end

      it 'creates the jobs (:backup, :restore)' do
        expect { post :create, params }.
          to change { JobTemplate.count }.by(2)
      end

      it 'redirects to host' do
        post :create, params
        expect(response).to redirect_to(host_path(host))
      end

      it 'calls save_and_create_restore_job' do
        JobTemplate.any_instance.
          should_receive(:save_and_create_restore_job).with('/foo')
        post :create, params
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
