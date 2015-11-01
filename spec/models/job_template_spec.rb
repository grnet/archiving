require 'spec_helper'

describe JobTemplate do
  context 'validates' do
    it 'name must be present' do
      expect(JobTemplate.new).to have(1).errors_on(:name)
    end

    it 'name must be unique on host\'s scope' do
      job_1 = FactoryGirl.create(:job_template, name: 'a name')
      job_2 = FactoryGirl.build(:job_template, name: 'a name')
      job_3 = FactoryGirl.build(:job_template, name: 'a name', host: job_1.host)
      expect(job_2).to be_valid
      expect(job_3).to_not be_valid
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

  # automatic assignments

  context 'when no job_type is given' do
    let(:job_template) { FactoryGirl.create(:job_template) }

    it 'sets the job_type to :backup' do
      expect(job_template).to be_backup
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

    it 'assigns Name param prefixed with the host\'s name' do
      expect(subject).to include("  Name = \"#{job_template.name_for_config}\"")
    end

    it 'assigns FileSet param' do
      expect(subject).to include("  FileSet = \"#{job_template.fileset.name}\"")
    end

    it 'assigns Client param' do
      expect(subject).to include("  Client = \"#{job_template.host.name}\"")
    end

    it 'assigns Type param' do
      expect(subject).to include("  Type = \"#{job_template.job_type.capitalize}\"")
    end

    it 'assigns Schedule param' do
      expect(subject).to include("  Schedule = \"#{job_template.schedule.name}\"")
    end

    context 'for a restore job' do
      let(:restore_job) { FactoryGirl.create(:job_template, :restore) }
      subject { restore_job.to_bacula_config_array }

      it 'does not assign a Schedule param' do
        expect(subject).to_not include("  Schedule = \"#{restore_job.schedule.name}\"")
      end

      it 'assigns Where param' do
        expect(subject).to include("  Where = \"#{restore_job.restore_location}\"")
      end
    end
  end

  describe '#save_and_create_restore_job' do
    let(:host) { FactoryGirl.create(:host) }
    let(:backup_job_template) do
      FactoryGirl.build(:job_template, job_type: nil, host: host)
    end

    it 'calls save' do
      backup_job_template.should_receive(:save)
      backup_job_template.save_and_create_restore_job
    end

    it 'creates a restore job for the same host' do
      expect { backup_job_template.save_and_create_restore_job }.
        to change { host.job_templates.restore.count }.by(1)
    end

    it 'creates a restore job for fileset' do
      backup_job_template.save_and_create_restore_job
      expect(host.job_templates.restore.pluck(:fileset_id)).
        to eq([backup_job_template.fileset_id])
    end
  end
end
