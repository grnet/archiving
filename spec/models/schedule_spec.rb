require 'spec_helper'

describe Schedule do
  context 'validates' do
    it 'presence of name' do
      expect(Schedule.new).to have(1).errors_on(:name)
    end

    it 'presence of runs' do
      expect(Schedule.new).to have(1).errors_on(:runs)
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
    let(:runs) do
      [
        'Full 1st sun at 23:05',
        'Differential 2nd-5th sun at 23:50',
        'Incremental mon-sat at 23:50'
      ]
    end

    let(:schedule) do
      FactoryGirl.create(:schedule, name: 'Test Schedule', runs: runs)
    end

    subject { schedule.to_bacula_config_array }

    it 'is a schedule type resource' do
      expect(subject.first).to eq('Schedule {')
      expect(subject.last).to eq('}')
    end

    it 'contains the name' do
      expect(subject).to include("  Name = \"#{[schedule.host.name, schedule.name].join(' ')}\"")
    end

    it 'contains the runs' do
      runs.each do |r|
        expect(subject).to include("  Run = #{r}")
      end
    end
  end
end
