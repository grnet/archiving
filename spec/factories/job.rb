FactoryGirl.define do
  factory :job do
    sequence(:Job) { |i| "Job #{i}" }
    sequence(:Name) { |i| "Job name #{i}" }
    type 'B'
    level 'F'
    job_status 'f'
    client
  end

  trait :running do
    job_status 'R'
  end
end
