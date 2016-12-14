FactoryGirl.define do
  factory :user do
    sequence(:username) { |n| "user-#{n}" }
    user_type 0
    sequence(:email) { |n| "user-#{n}@grnet.gr" }
  end

  trait :admin do
    after(:create) do |user|
      user.enabled = true
      user.admin!
    end
  end
end
