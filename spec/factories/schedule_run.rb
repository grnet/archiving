FactoryGirl.define do
  factory :schedule_run do
    schedule
    level 0
    day 'first sun'
    time '12:34'
  end
end
