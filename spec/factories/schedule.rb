FactoryGirl.define do
  factory :schedule do
    host
    sequence(:name) { |n| "Schedule #{n}" }
    runs ['Level=Full 1st sun at 2:05',
          'Level=Differential 2nd-5th sun at 2:05',
          'Level=Incremental mon-sat at 2:05']
  end
end
