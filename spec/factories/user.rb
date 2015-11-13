FactoryGirl.define do
  factory :user do
    sequence(:username) { |n| "user-#{n}" }
    user_type 0
  end
end
