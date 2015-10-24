require 'spec_helper'

describe Host do
  context 'validates' do
    [:name, :password].each do |field|
      it "presence of #{field}" do
        expect(Host.new).to have(1).errors_on(field)
      end
    end

    it 'numericality of :port' do
      expect(Host.new(port: :lala)).to have(2).errors_on(:port)
    end

    [:file_retention, :job_retention].each do |field|
      it "#{field} is set automatically" do
        host = Host.new
        host.valid?
        expect(host.send(field)).to be_present
      end
    end
  end

  context 'when fqdn is invalid' do
    let(:host) { FactoryGirl.build(:host, fqdn: :lala) }

    it 'has errors' do
      expect(host).to have(1).errors_on(:fqdn)
    end
  end

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
      expect(host.to_bacula_config_array).to include("  Catalog = #{Host::CATALOG}")
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
end
