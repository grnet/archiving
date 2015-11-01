require 'spec_helper'

describe JobTemplate do
  context 'validates' do
    it 'name must be present' do
      expect(JobTemplate.new).to have(1).errors_on(:name)
    end

    it 'fileset_id must be present' do
      expect(JobTemplate.new).to have(1).errors_on(:fileset_id)
    end

    it 'schedule_id must be present' do
      expect(JobTemplate.new).to have(1).errors_on(:schedule_id)
    end

    it 'schedule_id must NOT be present for :restore jobs' do
      expect(JobTemplate.new(job_type: :restore)).to have(0).errors_on(:schedule_id)
    end
  end

  describe '#to_bacula_config_array' do
    let(:job_template) { FactoryGirl.create(:job_template) }

    subject { job_template.to_bacula_config_array }

    it 'has a Job structure' do
      expect(subject.first).to eq('Job {')
      expect(subject.last).to eq('}')
    end

    JobTemplate::DEFAULT_OPTIONS.each do |k, v|
      it "assigns #{k.capitalize} param" do
        expect(subject).to include("  #{k.capitalize} = #{v}")
      end
    end
  end

  context 'when no job_type is given' do
    let(:job_template) { FactoryGirl.create(:job_template) }

    it 'sets the job_type to :backup' do
      expect(job_template).to be_backup
    end
  end
end
