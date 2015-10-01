FactoryGirl.define do
  factory :user do
    provider "facebook"
    sequence :uid do |n|
      n
    end
    username "John Doe"
    email "john.doe@example.com"
    latitude -15.950807
    longitude -5.688547
  end

end
