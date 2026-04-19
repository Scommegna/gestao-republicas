# spec/factories/users.rb

FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name  { Faker::Name.last_name }
    document   { Faker::Number.unique.number(digits: 11).to_s }
    phone      { "35999999999" }
    email      { Faker::Internet.unique.email }
    password   { "123456" }
    password_confirmation { "123456" }
    role { "user" }
  end
end
