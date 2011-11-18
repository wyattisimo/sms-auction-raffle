require 'rubygems'
require 'mongo'
require 'twilio-ruby'
require './local_settings'

#
# handles all raffle ticket functions
#
class Raffle
  
  def initialize(phone)
    
    # messages
    @help_msg = "*Txt [first_name] [last_name] to register\n*Txt LIST for prize list\n*Txt ADD [qty] to add tickets.\n*Txt QTY for ticket qty\n*Txt [item_num] to use ticket"
    
    @exception_msg = "Oh, snap. Something broke. Call 858 248 0841 for tech support."
    
    @register_msg = "Thanks for participating in the Raise Cache raffle, %s! 100%% of proceeds go to hackNY. You currently have %d raffle ticket%s to spend. Text LIST for prize list."
    @register_err = "Hi there! You're already registered. Text LIST to see a list of raffle prizes."

    @not_registered_msg = "You must register before you can participate in the raffle. Please register by texting your first and last name. Text HELP for help."
    
    @get_ticket_qty_msg = "You have %d raffle ticket%s."
    
    @list_line = "%d. %s\n"
    @list_msg = "*Text [number] to apply your raffle ticket."
    @list_more_msg = "\n*Text MORE for more."

    @apply_msg = "Great! One raffle ticket has been entered into the drawing for prize %d (%s). You have %d raffle tickets remaining."
    @apply_err = "Invalid prize number. Text LIST to see a list of raffle prizes."
    @apply_no_tickets_err = "You don't have any tickets. Text GET [quantity] to purchase more. Raffle tickets are $1 each."
    
    @add_msg = "Thanks! Tickets apply after payment. Pay with Venmo here:"
    @add_err = ""
    # end messages

    # max number of items to send when list is requested
    @list_size_limit = 4
    
    # initial number of tickets for new users
    @init_ticket_qty = 1
    
    @phone = phone
    
    @db_name = 'rc_raffle'
    @items_coll = 'prizes'
    @bidders_coll = 'hopefuls'

    @db = Mongo::Connection.new.db(@db_name)
  end
  
  #
  # helper: verifies the raffle participant is legit
  #
  def is_valid_bidder
    if @db[@bidders_coll].find_one('phone' => @phone) == nil then
      false
    else
      true
    end
  end
  
  #
  # returns the help msg
  #
  def get_help
    @help_msg
  end
  
  #
  # registers a new raffle participant
  #
  def register (name)
    result = @db[@bidders_coll].find_one('phone' => @phone)
    if result == nil then
      @db[@bidders_coll].insert({
        'name' => name,
        'phone' => @phone,
        'ticket_qty' => @init_ticket_qty
      })
      sprintf(@register_msg, name.split(' ')[0], @init_ticket_qty, @init_ticket_qty == 1 ? '' : 's')
    else
      @register_err
    end
  end
  
  #
  # returns the user's number of remaining raffle tickets
  #
  def get_ticket_qty
    return @not_registered_msg unless self.is_valid_bidder
    
    bidder = @db[@bidders_coll].find_one({ 'phone' => @phone })
    
    sprintf(@get_ticket_qty_msg, bidder['ticket_qty'], bidder['ticket_qty'] == 1 ? '' : 's')
  end
  
  #
  # lists n available raffle prizes, where n = @list_size_limit
  # if do_more is true, it continues from last, otherwise it starts at the beginning
  #
  def get_list(do_more)
    return @not_registered_msg unless self.is_valid_bidder
    
    bidder = @db[@bidders_coll].find_one({ 'phone' => @phone })
    
    if do_more == true
      last_item = bidder['last_item'] == nil ? 0 : bidder['last_item']
    else
      last_item = 0
    end
    
    more_msg = ''
    list = ''
    i = 0
    @db[@items_coll].find.sort('number').each do |item|
      i = i+1
      if i > last_item then
        # add item to list
        list += sprintf(@list_line, item['number'], item['name'])
      end
      
      if i >= last_item + @list_size_limit then
        # update the bidder's position in the list
        bidder['last_item'] = i
        @db[@bidders_coll].save(bidder)
        
        more_msg = @list_more_msg
        break
      end
    end
    
    "#{list}#{@list_msg}#{more_msg}"
  end
  
  #
  # applies a raffle ticket to the specified prize
  #
  def apply_ticket (prize_number)
    return @not_registered_msg unless self.is_valid_bidder
    
    apply_qty = 1
    prize_number = prize_number.to_i
    
    bidder = @db[@bidders_coll].find_one({ 'phone' => @phone })
    have_qty = bidder['ticket_qty'] ? bidder['ticket_qty'] : 0
    
    # ensure user has tickets
    return @apply_no_tickets_err if have_qty == 0
    
    prize = @db[@items_coll].find_one('number' => prize_number)
    
    # ensure valid prize
    return @apply_err if prize == nil
    
    # see if a record for this user already exists
    # if so, increment quantity
    does_exist = false
    prize['bids'].each do |b|
      if b['bidder_phone'] = @phone then
        b['quantity'] += apply_qty
        does_exist = true
        break
      end
    end
    
    # apply 1 ticket to item
    if does_exist then
      # update existing record
      @db[@items_coll].update(
        { 'number' => prize_number },
        { '$set' => { 'bids' => prize['bids'] } }
      )
    else
      # add a new record
      new_bid = {
        'ts' => Time.now.to_s,
        'bidder_phone' => @phone,
        'quantity' => apply_qty
      }
      @db[@items_coll].update(
        { 'number' => prize_number },
        { '$push' => { 'bids' => new_bid } }
      )
    end
    
    # deduct 1 ticket from user
    bidder['ticket_qty'] = bidder['ticket_qty'] ? bidder['ticket_qty'] - 1 : 0
    bidder['ticket_qty'] = 0 if bidder['ticket_qty'] < 0
    @db[@bidders_coll].save bidder
    
    sprintf(@apply_msg, prize['number'], prize['name'], bidder['ticket_qty'])
  end
  
  #
  # add more tickets
  #
  def add_tickets (qty)
    return @not_registered_msg unless self.is_valid_bidder
    
    self.send_venmo_invoice(qty)
    
    return
  end
  
  #
  # send Venmo invoice for given number of tickets
  #
  def send_venmo_invoice(qty)
    #651-357-0214
    msg = "https://venmo.com/?txn=Pay&recipients=6513570214&amount=#{qty}&note=for%20RaiseCache%20Raffle"
    @client = Twilio::REST::Client.new $account_sid, $auth_token
    @client.account.sms.messages.create(
      :from => $raffle_number,
      :to => @phone,
      :body => "#{@add_msg} #{msg}"
    )
  end
  
end