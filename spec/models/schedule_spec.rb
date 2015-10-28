require 'spec_helper'

describe Schedule do
  context 'validates' do
    it 'presence of name' do
      expect(Schedule.new).to have(1).errors_on(:name)
    end

    it 'presence of runs' do
      expect(Schedule.new).to have(1).errors_on(:runs)
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
      expect(subject).to include("  Name = \"#{schedule.name}\"")
    end

    it 'contains the runs' do
      runs.each do |r|
        expect(subject).to include("  Run = #{r}")
      end
    end
  end
end
