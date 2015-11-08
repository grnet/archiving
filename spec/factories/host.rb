FactoryGirl.define do
  factory :host do
    sequence(:fqdn) {|n| "lala.#{n}-#{rand(1000)}.gr" }
    password 'a strong password'
    port 1234
    file_retention 1
    job_retention 2
    baculized false

    trait :configured do
      status Host::STATUSES[:configured]
      job_templates { create_list :enabled_job_template, 1 }
      verified true
    end

    trait :updated do
      status Host::STATUSES[:updated]
      job_templates { create_list :enabled_job_template, 1 }
      verified true
    end

    trait :with_disabled_jobs do
      job_templates { create_list(:job_template, 1) }
      verified true
    end

    trait :with_enabled_jobs do
      job_templates { create_list :enabled_job_template, 1 }
    end
  end
end
