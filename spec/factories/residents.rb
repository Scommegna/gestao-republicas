FactoryBot.define do
  factory :resident do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    sequence(:phone) { |n| "3599999#{n.to_s.rjust(4, '0')}" }
    republica
  end
end