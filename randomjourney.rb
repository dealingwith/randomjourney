require 'mechanize'
require 'mailgun'
load 'config.rb'

# read file of links already sent out of text file
old_links = File.readlines(File.dirname(__FILE__) + '/links.txt')

mechanize = Mechanize.new
# use machanize to get archives page content
page = mechanize.get('http://www.danielsjourney.com/archives.html')
# get all the links in the page with the class 'archive_link'
link = page.links_with(class: 'archive_link').sample
# make sure it's a new one (not listed in links.txt)
while old_links.include? link.href do
  link = page.links_with(class: 'archive_link').sample
end
# get the href of the link
link_href = link.href
# get the text of the link
link_text = link.text
# create a new html string for the link
puts link_tag = "<a href=\"http://danielsjourney.com#{link_href}\">#{link_text}</a>"

# mailgun email sending
mg_client = Mailgun::Client.new MAILGUN_API_KEY
message_params = {:from    => 'daniel@danielsjourney.com',  
                  :to      => "dealingwith@gmail.com",
                  :subject => 'Here is your random danielsjourney post!',
                  :html    => link_tag}
mg_client.send_message MAILGUN_SANDBOX, message_params

# add the new link to the list in links.txt
File.open(File.dirname(__FILE__) + "/links.txt","a+") { |f| f.puts(link_href + "\n") }
