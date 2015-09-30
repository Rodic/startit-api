FactoryGirl.define do
  factory :event do
    start_latitude 44.841679
    start_longitude 20.490213
    start_time '2184-01-19 05:23:54+02'
    description "5 km morning run through park. Everyone is welcome"
    title "My running event"
    type ['Run', 'BikeRide'].sample
  end

  factory :run, parent: :event, class: 'Run' do
    type 'Run'
  end

  factory :bike_ride, parent: :event, class: 'BikeRide' do
    type 'BikeRide'
  end
end
