FactoryGirl.define do
  factory :client do
    sequence(:name) { |i| "Bacula Client #{i}" }
    uname 'Linux'
    auto_prune 1
    file_retention 30
    job_retention 40    
  end
end
