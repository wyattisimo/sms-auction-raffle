require 'rubygems'
require 'mongo'
require 'twilio-ruby'
require './local_settings'

db_name = 'rc_auction'
items_coll = 'items'
bidders_coll = 'bidders'
winners_coll = 'winners'

db = Mongo::Connection.new.db(db_name)

db[winners_coll].remove

puts
puts "AUCTION WINNERS..."
puts

# step through auction items and print winners
db[items_coll].find.sort('number').each do |item|
  
  puts "#{item['number']}. #{item['name']}: #{item['bids'].size} bids entered"
  
  if item['bids'] && item['bids'].size > 0 then
    item['bids'].sort_by! { |b| b['amount'].to_i }
    high = item['bids'].last
    winner = db[bidders_coll].find_one({ 'phone' => high['bidder_phone'] })
    
    puts "   WINNER: #{winner['name']} (#{winner['phone']}) #{high['bidder_phone']}"
  end
  
end