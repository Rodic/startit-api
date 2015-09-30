# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

20.times do
  lat  = rand(44.818711..44.827128)
  lon  = rand(20.449857..20.467388)
  time = rand(1..10).days.from_now
  desc = "My #{rand(4..100)}th run"
  type = ['Run', 'BikeRide'].sample

  Event.create(start_latitude: lat, start_longitude: lon, start_time: time, description: desc, type: type)
end
