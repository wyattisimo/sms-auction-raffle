require 'rubygems'
require 'mongo'

db_name = 'rc_auction'
items_coll = 'items'
bidders_coll = 'bidders'
unconfirmed_bids_coll = 'unconfirmed_bids'

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
  'name' => "Startup Starter",
  'info' => "Desk space, branding package, snacks, GA classes",
  'bids' => Array.new
})
db[items_coll].insert({
  'number' => 2,
  'name' => "Jetsetter",
  'info' => "750 jetsetter credit and trip advisor",
  'bids' => Array.new
})
db[items_coll].insert({
  'number' => 3,
  'name' => "Staycation",
  'info' => "1 night at Gansevoort, Gilt City Credit, Uber transport",
  'bids' => Array.new
})
db[items_coll].insert({
  'number' => 4,
  'name' => "Aha.life",
  'info' => "Fun goodies from Aha.life",
  'bids' => Array.new
})
db[items_coll].insert({
  'number' => 5,
  'name' => "Custom Avatar",
  'info' => "Designed by Alexis Moniello",
  'bids' => Array.new
})
db[items_coll].insert({
  'number' => 6,
  'name' => "Jack Robie",
  'info' => "4 jack robie custom shirts",
  'bids' => Array.new
})
db[items_coll].insert({
  'number' => 7,
  'name' => "Loom Decor",
  'info' => "250 Loom credit and inter decorator consult",
  'bids' => Array.new
})
db[items_coll].insert({
  'number' => 8,
  'name' => "Broodr",
  'info' => "Geeky soap, wand remote, yoda doormat",
  'bids' => Array.new
})
db[items_coll].insert({
  'number' => 9,
  'name' => "Fitted Fashion",
  'info' => "Custom tailoring for suit and shirts",
  'bids' => Array.new
})
db[items_coll].insert({
  'number' => 10,
  'name' => "Join Bklyn",
  'info' => "Private tour of BK museum, signed print",
  'bids' => Array.new
})
db[items_coll].insert({
  'number' => 11,
  'name' => "Newscred",
  'info' => "Newsfeed for your site, content consultation",
  'bids' => Array.new
})
db[items_coll].insert({
  'number' => 12,
  'name' => "CXXVI",
  'info' => "Shirt curated by Svpply",
  'bids' => Array.new
})
db[items_coll].insert({
  'number' => 13,
  'name' => "Wintercheck",
  'info' => "Scarf, Shot glass, wallet, curated by Svpply",
  'bids' => Array.new
})
db[items_coll].insert({
  'number' => 14,
  'name' => "DLC",
  'info' => "Chain bracelet, curated by Svpply",
  'bids' => Array.new
})
db[items_coll].insert({
  'number' => 15,
  'name' => "graham winters",
  'info' => "2 neck ties, curated by Svpply",
  'bids' => Array.new
})
