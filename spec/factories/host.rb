FactoryGirl.define do
  factory :host do
    sequence(:fqdn) {|n| "lala.#{n}-#{rand(1000)}.gr" }
    password 'a strong password'
    port 1234
    file_retention 1
    job_retention 2
    baculized false
  end
end
