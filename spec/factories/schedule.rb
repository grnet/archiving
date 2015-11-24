FactoryGirl.define do
  factory :schedule do
    host
    sequence(:name) { |n| "Schedule #{n}" }
  end
end
