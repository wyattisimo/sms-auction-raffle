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
test = 1
db[items_coll].find.sort('number').each do |item|
  
  puts "#{item['number']}. #{item['name']}: #{item['bids'].size} bids entered"
  
  if item['bids'] && item['bids'].size > 0 then
    item['bids'].sort_by! { |b| b['amount'].to_i }
    
    @client = Twilio::REST::Client.new $account_sid, $auth_token
    
    # notify winner ##############
    
    high = item['bids'].pop
    
    winner = db[bidders_coll].find_one({ 'phone' => high['bidder_phone'] })
    
    puts "   HIGH BID: $#{high['amount']}"
    puts "   WINNER:   #{winner['name']} (#{winner['phone']})"
    
    puts "   ...sending SMS to the winner..."
    win_msg = sprintf("Yay! You won the RaiseCache auction for \"#{item['name']}\"! Pls make your donation of $%d at http://bit.ly/c4hackny. We'll contact you to arrange delivery.", high['amount'])
    puts "   #{win_msg}"
    if test == 1 then
    @client.account.sms.messages.create(
      :from => $auction_number,
      :to => '+18582480841',#winner['phone'],
      :body => win_msg
    )
    end
  
    # save winner for posterity
    db[winners_coll].insert({
      'ts' => Time.now.to_s,
      'item_number' => item['number'],
      'item_name' => item['name'],
      'num_bids' => item['bids'].size,
      'high_bid' => high['amount'],
      'winner_name' => winner['name'],
      'winner_phone' => winner['phone']
    })
    
    # notify losers ##############
    
    puts "   ...sending SMS to the losers..."
    lose_msg = "Thanks for participating in the RaiseCache auction for \"#{item['name']}\"! Yours was not the highest bid, but RaiseCache for hackNY was a huge success!"
    
    sent = Array.new
    item['bids'].each do |bid|
      if sent.index(bid['bidder_phone']) === nil then
        puts "   (#{bid['bidder_phone']}) #{lose_msg}"
        if test == 1 then
        @client.account.sms.messages.create(
          :from => $auction_number,
          :to => '+18582480841',#bid['bidder_phone'],
          :body => lose_msg
        )
        end
      end
      sent.push bid['bidder_phone']
    end
    
  end
  
  test = 0
end