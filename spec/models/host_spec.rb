require 'spec_helper'

describe Host do
  context 'validates' do
    [:file_retention, :job_retention, :name, :password, :port].each do |field|
      it "#{field} is set automatically" do
        host = Host.new(fqdn: 'test')
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

  context 'name field' do
    let(:host) { FactoryGirl.create(:host, name: nil) }
    it 'is generated by the system' do
      expect(host.name).to be
    end
  end

  context 'quota field' do
    let(:host) { FactoryGirl.create(:host) }
    before do
      ConfigurationSetting.stub(:client_quota) { 1 }
    end

    it 'is generated by the system' do
      expect(host.quota).to eq(1)
    end
  end

  describe '#dispatch_to_bacula' do
    let(:configured_host) { FactoryGirl.create(:host, :configured) }
    let(:updated_host) { FactoryGirl.create(:host, :updated) }

    context 'for non verified hosts' do
      let(:unverified_host) { FactoryGirl.create(:host, :configured) }

      it 'returns false' do
        expect(unverified_host.dispatch_to_bacula).to eq(false)
      end
    end

    it 'calls BaculaHandler#deploy_config' do
      BaculaHandler.any_instance.should_receive(:deploy_config)
      configured_host.dispatch_to_bacula
    end

    context 'when the config does not reach bacula' do
      before do
        BaculaHandler.any_instance.should_receive(:send_config) { false }
      end

      it 'returns false' do
        expect(configured_host.dispatch_to_bacula).to eq(false)
      end

      it 'does not change the status of a configured host' do
        expect { configured_host.dispatch_to_bacula }.
          to_not change { configured_host.reload.status }
      end

      it 'does not change the status of an updated host' do
        expect { updated_host.dispatch_to_bacula }.
          to_not change { updated_host.reload.status }
      end
    end

    context 'when the config is sent to bacula' do
      before do
        BaculaHandler.any_instance.should_receive(:send_config) { true }
      end

      context 'and bacula gets reloaded' do
        before do
          BaculaHandler.any_instance.should_receive(:reload_bacula) { true }
        end

        it 'makes the configured host deployed' do
          configured_host.dispatch_to_bacula
          expect(configured_host.reload).to be_deployed
        end

        it 'makes the updated host deployed' do
          updated_host.dispatch_to_bacula
          expect(updated_host.reload).to be_deployed
        end
      end

      context 'but bacula fails to reload' do
        before do
          BaculaHandler.any_instance.should_receive(:reload_bacula) { false }
        end

        it 'makes the configured host dispatcheda' do
          configured_host.dispatch_to_bacula
          expect(configured_host.reload).to be_dispatched
        end

        it 'makes the updated host redispatched' do
          updated_host.dispatch_to_bacula
          expect(updated_host.reload).to be_redispatched
        end
      end
    end
  end

  describe '#remove_from_bacula' do
    let(:host) { FactoryGirl.create(:host, status: Host::STATUSES[:for_removal]) }

    context 'when the config is NOT removed from bacula' do
      before { BaculaHandler.any_instance.should_receive(:remove_config) { false } }

      it 'returns false' do
        expect(host.remove_from_bacula).to eq(false)
      end

      it 'does not alter the host\'s status' do
        expect { host.remove_from_bacula }.
          to_not change { host.reload.status }
      end
    end

    context 'when the config is removed from bacula' do
      before { BaculaHandler.any_instance.should_receive(:remove_config) { true } }

      context 'and bacula gets reloaded' do
        before { BaculaHandler.any_instance.should_receive(:reload_bacula) { true } }

        it 'returns true' do
          expect(host.remove_from_bacula).to eq(true)
        end

        it 'changes the host\'s status to pending' do
          expect { host.remove_from_bacula }.
            to change { host.reload.human_status_name }.from('for removal').to('pending')
        end
      end
    end
  end

  describe '#recalculate' do
    let(:host) { FactoryGirl.create(:host, :with_enabled_jobs) }

    [:configured, :updated, :blocked].each do |status|
      context "a #{status} host" do
        before { host.update_column(:status, Host::STATUSES[status]) }

        it "stays #{status}" do
          expect { host.recalculate }.to_not change { host.reload.status }
        end
      end
    end

    [:pending, :dispatched, :inactive].each do |status|
      context "a #{status} host" do
        before { host.update_column(:status, Host::STATUSES[status]) }

        it 'becomes configured' do
          expect { host.recalculate }.
            to change { host.reload.human_status_name }.
            from(host.human_status_name).to('configured')
        end
      end
    end

    context 'a dispatched host' do
      before { host.update_column(:status, Host::STATUSES[:dispatched]) }

      it 'becomes configured' do
        expect { host.recalculate }.
          to change { host.reload.human_status_name }.
          from('dispatched').to('configured')
      end
    end

    [:deployed, :redispatched, :for_removal].each do |status|
      context "a #{status} host" do
        before { host.update_column(:status, Host::STATUSES[status]) }

        it 'becomes updated' do
          expect { host.recalculate }.
            to change { host.reload.human_status_name }.
            from(host.human_status_name).to('updated')
        end
      end
    end
  end

  describe '#verify' do
    let!(:host) { FactoryGirl.create(:host, verified: false) }
    let(:admin) { FactoryGirl.create(:user, :admin) }

    it 'verifies host' do
      host.verify(admin.id)
      expect(host).to be_verified
    end

    it 'sets the verification credentials' do
      host.verify(admin.id)
      expect(host.verifier_id).to eq(admin.id)
      expect(host.verified_at).not_to be nil
    end
  end
end
