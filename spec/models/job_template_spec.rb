require 'spec_helper'

describe JobTemplate do
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
