require 'rubygems'
require 'mongo'

db_name = 'rc_raffle'
items_coll = 'prizes'
bidders_coll = 'hopefuls'
winners_coll = 'winners'

db = Mongo::Connection.new.db(db_name)


db[winners_coll].remove

puts "\nDRAWING RANDOM WINNERS FOR EACH RAFFLE ITEM...\n"

# step through the prizes and choose random winners
db[items_coll].find.sort('number').each do |prize|
  
  puts "#{prize['number']}. #{prize['name']}: #{prize['bids'].size} tickets entered"
  
  # pick random ticket
  r_index = rand(prize['bids'].size-1)
  puts "r_index: #{r_index}"
  winner = db[bidders_coll].find_one({ 'phone' => prize['bids'][r_index]['bidder_phone'] })
  puts "   WINNER: #{winner['name']} (#{winnder['phone']})"
  
  # list all tickets
  # prize['bids'].each do |bid|
  #   bidder = db[bidders_coll].find_one({ 'phone' => bid['bidder_phone'] })
  #   puts "    #{bidder['name']} #{bidder['phone']}"
  # end
end
