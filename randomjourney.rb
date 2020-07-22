require 'mechanize'

# read file of links already sent out of text file
old_links = File.readlines(File.dirname(__FILE__) + '/links.txt')

mechanize = Mechanize.new
# use machanize to get archives page content
page = mechanize.get('http://daniel.industries/archives')
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
puts 'http://daniel.industries' + link_href
# add the new link to the list in links.txt
File.open(File.dirname(__FILE__) + "/links.txt","a+") { |f| f.puts(link_href + "\n") }
