require 'rubygems'
require 'mongo'

db_name = 'rc_raffle'
items_coll = 'prizes'
bidders_coll = 'hopefuls'

db = Mongo::Connection.new.db(db_name)

db[items_coll].remove

# (1..15).each do |i|
#   db[items_coll].insert({
#     'number' => i,
#     'name' => "Item #{i}",
#     'info' => "This is the info for auction item #{i}.",
#     'bids' => Array.new
#   })
# end

# real data

db[items_coll].insert({
  'number' => 1,
  'name' => "Starter Startup",
  'info' => "Office space, programming, snacks, GA classes",
  'bids' => Array.new
})
db[items_coll].insert({
  'number' => 2,
  'name' => "NY Girl Style",
  'info' => "Rent the Runway Credit, Warby Parker glasses",
  'bids' => Array.new
})
db[items_coll].insert({
  'number' => 3,
  'name' => "NY Guy Style",
  'info' => "Bonobos credit, Warby Parker glasses",
  'bids' => Array.new
})
db[items_coll].insert({
  'number' => 4,
  'name' => "Chloe + Isabel",
  'info' => "Jewelry Set",
  'bids' => Array.new
})
db[items_coll].insert({
  'number' => 5,
  'name' => "Broodr",
  'info' => "Geeky soap, Yoda Doormat, Wand Remote",
  'bids' => Array.new
})
db[items_coll].insert({
  'number' => 6,
  'name' => "Small Girls",
  'info' => "Clutch, necktie, glasses, refashioner credit",
  'bids' => Array.new
})
db[items_coll].insert({
  'number' => 7,
  'name' => "Fun Weekend",
  'info' => "Movie passes, X box kinect, x box live membership",
  'bids' => Array.new
})
db[items_coll].insert({
  'number' => 8,
  'name' => "Other Fun Weekend",
  'info' => "Movie passes, Xbox kinect, Xbox live membership",
  'bids' => Array.new
})
db[items_coll].insert({
  'number' => 9,
  'name' => "Something Borrowed",
  'info' => "$400 Bridesmaid dress rental",
  'bids' => Array.new
})
db[items_coll].insert({
  'number' => 10,
  'name' => "Artsicle",
  'info' => "6 month art rental",
  'bids' => Array.new
})
