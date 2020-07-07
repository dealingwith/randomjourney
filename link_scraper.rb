require 'mechanize'

url = ARGV[0]

mechanize = Mechanize.new

page = mechanize.get(url)

page.links.each do |link|
  # todo: check link
  puts link.href
end