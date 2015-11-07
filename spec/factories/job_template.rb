FactoryGirl.define do
  factory :jobtemplate, class: JobTemplate do
    host
    fileset
    sequence(:name) { |n| "Job #{n}" }

    trait :backup do
      job_type :backup
      schedule
    end

    trait :restore do
      job_type :restore
      restore_location '/tmp'
    end

    trait :enabled do
      enabled true
    end

    factory :job_template, traits: [:backup]
    factory :enabled_job_template, traits: [:backup, :enabled]
  end
end
