require 'spec_helper'

describe ClientsController do
  describe 'GET #index' do
    let!(:job) { FactoryGirl.create(:job) }
    let!(:running_job) { FactoryGirl.create(:job, :running) }

    before { get :index }

    it 'fetches clients' do
      expect(assigns(:clients)).to be
    end

    it 'fetches hosts' do
      expect(assigns(:hosts)).to be
    end

    it 'fetches active jobs' do
      expect(assigns(:active_jobs)).to eq(Hash[running_job.client_id, 1])
    end

    it 'renders' do
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #show' do
    let(:client) { FactoryGirl.create(:client) }

    before { get :show, id: client.id }

    it 'fetches client' do
      expect(assigns(:client)).to eq(client)
    end

    it 'renders' do
      expect(response).to render_template(:show)
    end
  end
end
