require 'gmail'
require 'json'
require 'date'
require 'debugger'

def get_dates(start_date, end_date)
  retval = []
  curr = start_date
  while(curr < end_date)
    nxt = DateTime.new(curr.year, curr.month).next_month
    retval << {:start=>curr, :end=>nxt}
    curr = nxt
  end
  return retval
end

@env = ENV['ENV'] ||= 'development'
config = YAML.load_file 'config/karl.yml'
$cfg = config[@env]

$gmail = $cfg["gmail"]
stats = {}
from = Hash.new(0)
stats[:labels] = {}
stats[:ranges] = {}

puts "connecting"
Gmail.connect($gmail["username"], $gmail["password"]) do |gmail|
=begin
puts "gathering total"
  stats[:total]  = gmail.mailbox("[Gmail]/All Mail").emails.count
puts "gathering unread"
  stats[:unread] = gmail.inbox.count(:unread)
puts "gathering total"
  stats[:read]   = gmail.inbox.count(:read)

puts "checking #{gmail.labels.count} labels"
  gmail.labels.each do |label|
    print '.'
    begin
    stats[:labels][label] = gmail.mailbox(label).count
    rescue Net::IMAP::NoResponseError => ex
    end
  end
  print "\n"
=end

puts "emails"
gmail.mailbox("[Gmail]/All Mail").emails.each do |email|
  puts email.envelope.subject
  puts email.message.text_part.body.to_s.split(/[ ,\n]*/).inspect
end

puts "earliest email"
mail = gmail.mailbox("[Gmail]/All Mail").emails.first
date = DateTime.parse(mail.envelope.date)
dates = get_dates(date, DateTime.now)

puts "getting counts for #{dates.size} months"
dates.each do |range|
  print '.'
  stats[:ranges][range[:start]] = gmail.mailbox("[Gmail]/All Mail").find(:before=>range[:end], :after=>range[:begin]).count
end
print "\n"
end

puts stats.to_json
