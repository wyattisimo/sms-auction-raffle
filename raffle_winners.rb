require 'rubygems'
require 'mongo'
require 'twilio-ruby'
require './local_settings'

db_name = 'rc_raffle'
items_coll = 'prizes'
bidders_coll = 'hopefuls'
winners_coll = 'winners'

db = Mongo::Connection.new.db(db_name)


db[winners_coll].remove

puts
puts "DRAWING RANDOM WINNERS FOR EACH RAFFLE ITEM..."
puts

# step through the prizes and choose random winners
db[items_coll].find.sort('number').each do |prize|
  
  puts "#{prize['number']}. #{prize['name']}: #{prize['bids'].size} tickets entered"
  
  # pick random ticket
  if prize['bids'].size > 0 then
    r_index = rand(prize['bids'].size)
    winner = db[bidders_coll].find_one({ 'phone' => prize['bids'][r_index]['bidder_phone'] })
    puts "   WINNER: #{winner['name']} (#{winner['phone']})"
    
    # notify winner
    puts "   ...sending sms to the winner..."
    msg = sprintf("Congratulations! You won a RaiseCache Raffle prize: (#{prize['name']}).\nbla bla bla to redeem your prize.")
    puts msg
    # @client = Twilio::REST::Client.new $account_sid, $auth_token
    # @client.account.sms.messages.create(
    #   :from => $raffle_number,
    #   :to => winner['phone'],
    #   :body => msg
    # )
    
    # save for posterity
    db[winners_coll].insert({
      'ts' => Time.now.to_s,
      'prize_number' => prize['number'],
      'prize_name' => prize['name'],
      'winner_name' => winner['name'],
      'winner_phone' => winner['phone']
    })
  end
  
  # list all tickets
  # prize['bids'].each do |bid|
  #   bidder = db[bidders_coll].find_one({ 'phone' => bid['bidder_phone'] })
  #   puts "    #{bidder['name']} #{bidder['phone']}"
  # end
end
