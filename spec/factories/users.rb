FactoryBot.define do
  factory :user do
    nickname { Faker::Name.name }
    email { Faker::Internet.unique.email }
    password { 'abc123' }
    password_confirmation { 'abc123' }
    last_name { '山田' }
    first_name { '太郎' }
    last_name_kana { 'ヤマダ' }
    first_name_kana { 'タロウ' }
    birth_date { Faker::Date.birthday(min_age: 18, max_age: 65) }
  end
end
