require 'rubygems'
require 'sinatra'
require 'haml'
require 'twilio-ruby'
require 'mongo'
require './lib/auction'
require './lib/raffle'

bad_command_msg = "ehh... I don't know what to do with that. Text HELP for instructions."

get '/' do
  "Stop looking at me."
end

#
# stats
#

get %r{/stats/?} do
  auction = Auction.new('admin')
  raffle = Raffle.new('admin')
  
  # AUCTION DATA
  items = auction.get_all_items
  @items = Array.new
  @auction_net_revenue = 0
  i = 0
  items.each do |item|
    @items[i] = item
    b = 0
    item['bids'].each do |bid|
      bidder = auction.get_bidder(bid['bidder_phone'])
      @items[i]['bids'][b]['bidder_name'] = bidder['name']
      b += 1
    end
    @items[i]['bids'].sort_by! { |b| b['amount'] }
    @items[i]['bids'].reverse!
    @items[i]['high_bid'] = @items[i]['bids'].size > 0 ? @items[i]['bids'][0]['amount'] : 0
    @auction_net_revenue += @items[i]['high_bid']
    i += 1
  end
  
  # RAFFLE DATA
  prizes = raffle.get_all_prizes
  @prizes = Array.new
  @raffle_total_tickets = 0
  p = 0
  prizes.each do |prize|
    @prizes[p] = prize
    b = 0
    prize['bids'].each do |bid|
      bidder = raffle.get_bidder(bid['bidder_phone'])
      @prizes[p]['bids'][b]['bidder_name'] = bidder['name']
      b += 1
    end
    @raffle_total_tickets += b
    @prizes[p]['bids'].sort_by! { |b| b['ts'] }
    @prizes[p]['bids'].reverse!
    p += 1
  end
  
  haml :stats
end

#
# AUCTION
#

get %r{/auction/voice/?} do
  headers['Content-Type'] = 'text/xml; charset=utf8'
  xmldoc = Twilio::TwiML::Response.new do |r|
    r.Say 'Welcome to the Raise Cache auction! Too register for the auction, please text your first and last name to 4 8 4, 7 7, cache. Thats 4 8 4, 7 7, C A C H E'
  end
  xmldoc.text
end

get %r{/auction/sms/?} do
  
  phone = params['From'] == nil ? '' : params['From']
  msg = params['Body'] == nil ? '' : params['Body'].strip
  
  auction = Auction.new(phone)
  
  case msg
  
  # register
  when /^[a-z-.]+\s[a-z-.]+$/i
    response = auction.register(msg)
  
  # list auction items
  when /^LIST$/i
    response = auction.get_list(nil)
  
  # list more auction items
  when /^MORE$/i
    response = auction.get_list(true)

  # show auction item info
  when /^\d+$/
    response = auction.get_info(msg)
  
  # bid
  when /^\d+\s\$?\d+$/
    bid = msg.split ' '
    response = auction.bid(bid[0], bid[1].sub('$',''))
  
  # confirm bid
  when /^(YES|NO)$/i
    response = auction.confirm_bid(msg)
  
  # show help
  when /^HELP$/i
    response = auction.get_help
  
  # psheww-psheww-psheww!
  else
    response = bad_command_msg
    
  end
  
  # respond
  headers['Content-Type'] = 'text/xml; charset=utf8'
  xmldoc = Twilio::TwiML::Response.new do |r|
    r.Sms response
  end
  xmldoc.text
end

#
# RAFFLE
#

# receive venmo payment notices
post %r{/raffle/payment/?} do
  "#{params[:foo]}"
end
get %r{/raffle/add/?} do
  raffle = Raffle.new "+#{params[:p]}"
  raffle.do_add_tickets params[:a]
end

get %r{/raffle/voice/?} do
  headers['Content-Type'] = 'text/xml; charset=utf8'
  xmldoc = Twilio::TwiML::Response.new do |r|
    r.Say 'Welcome to the Raise Cache raffle! Too register for the raffle, please text your name and ticket number to 3 0 4, 4 6, cache. Thats 3 0 4, 4 6, C A C H E'
  end
  xmldoc.text
end

get %r{/raffle/sms/?} do
  
  phone = params['From'] == nil ? '' : params['From']
  msg = params['Body'] == nil ? '' : params['Body'].strip
  
  raffle = Raffle.new(phone)
  
  case msg
  
  # show help
  when /^HELP$/i
    response = raffle.get_help

  # register
  when /^[a-z-.]+\s[a-z-.]+$/i
    response = raffle.register(msg)
  
  # get remaining number of tickets
  when /^QTY$/i
    response = raffle.get_ticket_qty

  # list raffle prizes
  when /^LIST$/i
    response = raffle.get_list(nil)

  # list more raffle items
  when /^MORE$/i
    response = raffle.get_list(true)
  
  # apply raffle ticket
  when /^\d+$/
    response = raffle.apply_ticket(msg)
  
  # get more tickets
  when /^ADD\s\d+$/i
    qty = msg.split(' ')[1]
    response = raffle.add_tickets(qty)

  # psheww-psheww-psheww!
  else
    response = bad_command_msg
    
  end
  
  # respond
  headers['Content-Type'] = 'text/xml; charset=utf8'
  xmldoc = Twilio::TwiML::Response.new do |r|
    r.Sms response
  end
  xmldoc.text
end


not_found do
  status 404
  "um... no."
end
