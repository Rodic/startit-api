# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# 20.times do
#   lat  = rand(44.818711..44.827128)
#   lon  = rand(20.449857..20.467388)
#   time = rand(1..10).days.from_now
#   desc = "My #{rand(4..100)}th run"
#   type = ['Run', 'BikeRide'].sample
#
#   Event.create(start_latitude: lat, start_longitude: lon, start_time: time, description: desc, type: type)
# end

u = User.create(
  provider: "facebook",
  uid: "123456",
  username: "rodic",
  latitude: 44.818611,
  longitude: 20.468056
)

events = [
  {
    start_latitude: '0.448415899E2',
    start_longitude: '0.204901574E2',
    start_time: "2015-10-06 09:00:00",
    description: "Easy 5 km run around Metro. Should take about 30 mins. Everyone is welcome!",
    title: "morning run",
    type: "Run",
    creator: u
  },
  {
    start_latitude: '0.448394598E2',
    start_longitude:'0.204987405E2',
    start_time: "2015-10-13 18:00:00",
    description: "Bike ride to Pancevo and back!",
    title: nil,
    type: "BikeRide",
    creator: u
  },
  {
    start_latitude: '0.447930648E2',
    start_longitude: '0.204480145E2',
    start_time: "2015-10-10 23:00:00",
    description: "Evening run through Hyde Park. About 7 km in 40 minutes!",
    title: "Hyde Park Run",
    type: "Run",
    creator: u
  },
  {
    start_latitude: '0.448029314E2',
    start_longitude: '0.20510628E2',
    start_time: "2015-10-28 17:00:00",
    description: "Relaxing drive through Zvezdarska suma. No plans for distance or duration.",
    title: nil,
    type: "BikeRide",
    creator: u
  },
  {
    start_latitude: '0.447887096E2',
    start_longitude: '0.204081462E2',
    start_time: "2015-10-10 08:00:00",
    description: "Saturday morning run on Ada Ciganlija. Two circles, should be about 15 km, easy tempo.",
    title: "Ada weekend run",
    type: "Run",
    creator_id: u
  },
  {
    start_latitude: '0.447702494E2',
    start_longitude: '0.204375861E2',
    start_time: "2015-10-17 18:00:00",
    description: "High tempo ride through Kosutnjak. Experienced bikers are welcomed! Intense 2 hrs!",
    title: "Kosutnjak bike ride",
    type: "BikeRide",
    creator_id: u
  }
]

events.each do |e|
  Event.create(e)
end
