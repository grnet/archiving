FactoryGirl.define do
  factory :job_template do
    host
    fileset
    schedule
    sequence(:name) { |n| "Job #{n}" }
    job_type :backup
  end
end
