FactoryGirl.define do
  factory :event do
    start_latitude  { rand * 90  * [1, -1].sample }
    start_longitude { rand * 180 * [1, -1].sample }
    start_time      { rand(1..30).days.from_now }
    description     { "#{rand(1..10)} km morning #{%w( run ride).sample}!" }
    type            ['Run', 'BikeRide'].sample
    association :creator, factory: :user
  end

  factory :run, parent: :event, class: Run do
    type 'Run'
  end

  factory :bike_ride, parent: :event, class: BikeRide do
    type 'BikeRide'
  end
end
