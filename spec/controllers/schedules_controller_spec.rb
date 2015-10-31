require 'spec_helper'

describe SchedulesController do
  describe 'GET #new' do
    before { get :new }

    it 'initializes a schedule' do
      expect(assigns(:schedule)).to be
    end

    it 'renders' do
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      let(:params) do
        {
          schedule: { name: FactoryGirl.build(:schedule).name, runtime: '19:17' }
        }
      end

      it 'creates the schedule' do
        expect { post :create, params }.
          to change { Schedule.count }.by(1)
      end

      it 'redirects to root' do
        post :create, params
        expect(response).to redirect_to(root_path)
      end
    end

    context 'with invalid params' do
      let(:params) { { schedule: { invalide: :foo } } }

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
    end
  end
end
