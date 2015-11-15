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

  context 'when enabling a job' do

    [:pending, :dispatched].each do |status|
      context "of a #{status} host" do
        let(:host) { FactoryGirl.create(:host) }
        let!(:job) { FactoryGirl.create(:job_template, host: host) }

        before { host.update_column(:status, Host::STATUSES[status]) }

        it 'becomes configured' do
          expect {
            job.enabled = true
            job.save
          }.to change {
            host.reload.human_status_name
          }.from(status.to_s).to('configured')
        end
      end
    end

    context 'of a configured host' do
      let(:host) { FactoryGirl.create(:host) }
      let!(:job) { FactoryGirl.create(:job_template, host: host) }

      before { host.update_column(:status, Host::STATUSES[:configured]) }

      it 'stays configured' do
        expect {
          job.enabled = true
          job.save
        }.to_not change { host.reload.human_status_name }
      end
    end

    context 'of a updated host' do
      let(:host) { FactoryGirl.create(:host) }
      let!(:job) { FactoryGirl.create(:job_template, host: host) }

      before { host.update_column(:status, Host::STATUSES[:updated]) }

      it 'stays updated' do
        expect {
          job.enabled = true
          job.save
        }.to_not change { host.reload.human_status_name }
      end
    end

    [:deployed, :redispatched].each do |status|
      context "of a #{status} host" do
        let(:host) { FactoryGirl.create(:host) }
        let!(:job) { FactoryGirl.create(:job_template, host: host) }

        before { host.update_column(:status, Host::STATUSES[status]) }

        it 'becomes updated' do
          expect {
            job.enabled = true
            job.save
          }.to change {
            host.reload.human_status_name
          }.from(status.to_s).to('updated')
        end
      end
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
      expect(subject).to include("  FileSet = \"#{job_template.fileset.name_for_config}\"")
    end

    it 'assigns Client param' do
      expect(subject).to include("  Client = \"#{job_template.host.name}\"")
    end

    it 'assigns Type param' do
      expect(subject).to include("  Type = \"#{job_template.job_type.capitalize}\"")
    end

    it 'assigns Schedule param' do
      expect(subject).to include("  Schedule = \"#{job_template.schedule.name_for_config}\"")
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
end
