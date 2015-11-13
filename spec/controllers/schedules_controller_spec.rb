require 'spec_helper'

describe SchedulesController do
  let(:host) { FactoryGirl.create(:host) }
  let(:user) { FactoryGirl.create(:user) }

  before do
    host.users << user
    controller.stub(:current_user) { user }
  end

  describe 'GET #new' do
    before { get :new, host_id: host.id }

    it 'initializes a schedule' do
      expect(assigns(:schedule)).to be
    end

    it 'sets the schedule\'s host' do
      expect(assigns(:schedule).host).to eq(host)
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
          schedule: { name: FactoryGirl.build(:schedule).name, runtime: '19:17' }
        }
      end

      it 'creates the schedule' do
        expect { post :create, params }.
          to change { host.schedules(true).count }.by(1)
      end

      it 'redirects to a new job form' do
        post :create, params
        expect(response).to redirect_to(new_host_job_path(host, schedule_id: Schedule.last.id))
      end

      context 'and an existing job' do
        let(:job) { FactoryGirl.create(:job_template, host: host) }

        it 'redirects to the job\'s edit form' do
          post :create, params.merge(job_id: job.id)
          expect(response).
            to redirect_to(edit_host_job_path(host, job, schedule_id: Schedule.last.id))
        end
      end
    end

    context 'with invalid host' do
      it 'raises not found error' do
        expect {
          post :create, { host_id: -1, schedule: { invalid: true } }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'with invalid params' do
      let(:params) do
        {
          host_id: host.id,
          schedule: { invalide: :foo }
        }
      end

      it 'initializes a schedule with errors' do
        post :create, params
        expect(assigns(:schedule)).to be
      end

      it 'does not create the schedule' do
        expect { post :create, params }.
          to_not change { Schedule.count }
      end

      it 'renders :new' do
        post :create, params
        expect(response).to render_template(:new)
      end

      it 'assigns the host to schedule' do
        post :create, params
        expect(assigns(:schedule).host).to eq(host)
      end
    end
  end
end
