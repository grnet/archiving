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
    end

    factory :job_template, traits: [:backup]
  end
end
