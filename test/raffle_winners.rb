require 'rubygems'
require 'mongo'

db_name = 'rc_raffle'
items_coll = 'prizes'
bidders_coll = 'hopefuls'
winners_coll = 'winners'

db = Mongo::Connection.new.db(db_name)


db[winners_coll].remove

# step through the prizes and choose random winners
db[items_coll].find.sort('number').each do |prize|
  
  puts "#{prize['number']}. #{prize['name']}: size #{prize['bids'].size}"
  prize.bids.each do |bid|
    bidder = db[bidders_coll].find_one({ 'number' => bid['bidder_phone'] })
    puts "    #{bidder['name']} #{bidder['number']} #{bid['bidder_number']}"
  end
end
