require 'spec_helper'

describe Schedule do
  context 'validates' do
    it 'presence of name' do
      expect(Schedule.new).to have(2).errors_on(:name)
    end

    context 'schedule name is unique in the host\'s scope' do
      let!(:schedule_1) { FactoryGirl.create(:schedule, name: 'Schedule_1') }
      let(:schedule_2) { FactoryGirl.build(:schedule, name: 'Schedule_1') }
      let(:schedule_3) { FactoryGirl.build(:schedule, name: 'Schedule_1', host: schedule_1.host) }

      it 'two schedules of diferent hosts can have the same name' do
        expect(schedule_2).to be_valid
      end

      it 'two schedules of the same host can NOT have the same name' do
        expect(schedule_3).to_not be_valid
      end
    end
  end

  describe '#to_bacula_config_array' do
    let(:schedule) do
      FactoryGirl.create(:schedule, name: 'Test Schedule')
    end

    let!(:schedule_run) { FactoryGirl.create(:schedule_run, schedule: schedule) }

    subject { schedule.to_bacula_config_array }

    it 'is a schedule type resource' do
      expect(subject.first).to eq('Schedule {')
      expect(subject.last).to eq('}')
    end

    it 'contains the name' do
      expect(subject).to include("  Name = \"#{[schedule.host.name, schedule.name].join(' ')}\"")
    end

    it 'contains the runs' do
      expect(subject).to include("  Run = #{schedule.schedule_runs.first.schedule_line}")
    end
  end
end
