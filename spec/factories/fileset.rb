FactoryGirl.define do
  factory :fileset do
    sequence(:name) { |n| "Fileset #{n}" }
    exclude_directions []
    include_directions {}
    host
  end
end