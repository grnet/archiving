require 'spec_helper'

describe Configuration::Host do
  describe '#to_bacula_config_array' do
    let(:host) { FactoryGirl.create(:host) }

    it "is a valid client directive" do
      expect(host.to_bacula_config_array).to include('Client {')
      expect(host.to_bacula_config_array).to include('}')
    end

    it "contains Address directive" do
      expect(host.to_bacula_config_array).to include("  Address = #{host.fqdn}")
    end

    it "contains FDPort directive" do
      expect(host.to_bacula_config_array).to include("  FDPort = #{host.port}")
    end

    it "contains Catalog directive" do
      expect(host.to_bacula_config_array).
        to include("  Catalog = #{ConfigurationSetting.current_client_settings[:catalog]}")
    end

    it "contains Password directive" do
      expect(host.to_bacula_config_array).to include("  Password = \"#{host.password}\"")
    end

    it "contains File Retention directive" do
      expect(host.to_bacula_config_array).
        to include("  File Retention = #{host.file_retention} days")
    end

    it "contains Job Retention directive" do
      expect(host.to_bacula_config_array).
        to include("  Job Retention = #{host.job_retention} days")
    end

    it "contains AutoPrune directive" do
      expect(host.to_bacula_config_array).to include("  AutoPrune = yes")
    end
  end

  describe '#baculize_config' do
    let!(:host) { FactoryGirl.create(:host) }

    let!(:fileset) { FactoryGirl.create(:fileset, host: host) }
    let!(:other_fileset) { FactoryGirl.create(:fileset, host: host) }

    let!(:schedule) { FactoryGirl.create(:schedule) }
    let!(:other_schedule) { FactoryGirl.create(:schedule) }

    let!(:enabled_job) do
      FactoryGirl.create(:job_template, host: host, schedule: schedule,
                         fileset: fileset, enabled: true)
    end
    let!(:disabled_job) do
      FactoryGirl.create(:job_template, host: host, schedule: other_schedule,
                         fileset: other_fileset, enabled: false)
    end

    subject { host.baculize_config }

    it 'includes the client\'s config' do
      expect(subject).to include(host.to_bacula_config_array)
    end

    it 'includes the all the job template\'s configs' do
      expect(subject).to include(enabled_job.to_bacula_config_array)
      expect(subject).to include(disabled_job.to_bacula_config_array)
    end

    it 'includes all the used schedules\'s configs' do
      expect(subject).to include(schedule.to_bacula_config_array)
      expect(subject).to include(other_schedule.to_bacula_config_array)
    end

    it 'includes all the used filesets\'s configs' do
      expect(subject).to include(fileset.to_bacula_config_array)
      expect(subject).to include(other_fileset.to_bacula_config_array)
    end
  end

  describe '#bacula_fd_director_config' do
    let!(:host) { FactoryGirl.build(:host) }

    subject { host.bacula_fd_director_config }

    it 'opens and closes a Director part' do
      expect(subject).to match(/^Director {$/)
      expect(subject).to match(/^}$/)
    end

    it 'includes the client\'s Name' do
      expect(subject).to match("  Name = \"#{Archiving.settings[:director_name]}\"")
    end

    it 'includes the client\'s Password' do
      expect(subject).to match("  Password = \"[*]+\"")
    end
  end

  describe '#bacula_fd_filedaemon_config' do
    let!(:host) { FactoryGirl.build(:host) }

    subject { host.bacula_fd_filedaemon_config }

    it 'opens and closes a FileDaemon part' do
      expect(subject).to match(/^FileDaemon {$/)
      expect(subject).to match(/^}$/)
    end

    it 'includes the client\'s Port' do
      expect(subject).to match("FDport = #{host.port}")
    end

    it 'includes the client\'s Name' do
      expect(subject).to match("Name = #{host.name}")
    end
  end
end
