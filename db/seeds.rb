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

providers = [ "facebook", "google" ]

users = []

30.times do
  user = User.create do |u|
    u.provider = providers.sample
    u.uid = rand(1_000_000)
    u.username = Faker::Internet.user_name
    u.email = Faker::Internet.free_email(u.username)
    u.latitude  = 44.818611 + rand(10) / 10_000.0 * [1, -1].sample
    u.longitude = 20.468056 + rand(10) / 10_000.0 * [1, -1].sample
  end
  puts "Creating user - #{user.username}"
  users << user
end

events = [
  {
    start_latitude: '0.448415899E2',
    start_longitude: '0.204901574E2',
    start_time: "2025-10-06 09:00:00",
    description: "Easy 5 km run around Metro. Should take about 30 mins. Everyone is welcome!",
    title: "morning run",
    type: "Run"
  },
  {
    start_latitude: '0.448394598E2',
    start_longitude:'0.204987405E2',
    start_time: "2025-10-13 18:00:00",
    description: "Bike ride to Pancevo and back!",
    title: nil,
    type: "BikeRide"
  },
  {
    start_latitude: '0.447930648E2',
    start_longitude: '0.204480145E2',
    start_time: "2025-10-10 23:00:00",
    description: "Evening run through Hyde Park. About 7 km in 40 minutes!",
    title: "Hyde Park Run",
    type: "Run"
  },
  {
    start_latitude: '0.448029314E2',
    start_longitude: '0.20510628E2',
    start_time: "2025-10-28 17:00:00",
    description: "Relaxing drive through Zvezdarska suma. No plans for distance or duration.",
    title: nil,
    type: "BikeRide"
  },
  {
    start_latitude: '0.447887096E2',
    start_longitude: '0.204081462E2',
    start_time: "2025-10-10 08:00:00",
    description: "Saturday morning run on Ada Ciganlija. Two laps, should be about 15 km, easy tempo.",
    title: "Ada weekend run",
    type: "Run"
  },
  {
    start_latitude: '0.447702494E2',
    start_longitude: '0.204375861E2',
    start_time: "2025-10-17 18:00:00",
    description: "High tempo ride through Kosutnjak. Experienced bikers are welcomed! Intense 2 hrs!",
    title: "Kosutnjak bike ride",
    type: "BikeRide"
  },
  {
    start_latitude: "0.447829224E2",
    start_longitude: "0.20437157E2",
    start_time: "2025 Oct 15 12:00:00",
    description: "Run through Topčiderski park! Mid tempo (about 6 mins per km).",
    title: "Topčider",
    type: "Run"
  },
  {
    start_latitude: "0.447877654E2",
    start_longitude: "0.204155169E2",
    start_time: "2025 Oct 28 18:45:00",
    description: "Bike ride on Ada. No fitness goals, everyone is welcome!",
    title: nil,
    type: "BikeRide"
  },
  {
    start_latitude: "0.447971837E2",
    start_longitude: "0.204053567E2",
    start_time: "2015 Oct 25 07:00:00",
    description: "A few laps around Savski kej. Early morning run.",
    title: "Savski kej",
    type: "Run"
  },
  {
    start_latitude: "0.448152775E2",
    start_longitude: "0.204462148E2",
    start_time: "2015 Oct 14 20:50:00",
    description: "Evening run on Ušće. It will take 30 mins for 6 kms.",
    title: nil,
    type: "Run"
  }
]

events.each do |e|
  event = Event.new(e)
  event.start_time_utc = event.start_time - 2.hours
  event.creator = users.sample

  puts "\n#{'=' * 80}\nCreating event - #{event.title || event.description}"
  
  participants = users.sample(rand(10))
  participants.each do |u|
    puts "\tAdding participant - #{u.username}"
    event.participants << u if u != event.creator
  end

  event.save(validate: false)
end
