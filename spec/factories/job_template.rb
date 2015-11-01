FactoryGirl.define do
  factory :job_template do
    host
    fileset
    schedule
    sequence(:name) { |n| "Job #{n}" }
  end
end
