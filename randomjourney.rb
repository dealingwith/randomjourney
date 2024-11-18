require "mechanize"
require "typhoeus"
require "ruby-link-checker" # https://github.com/dblock/ruby-link-checker/

# read file of links already sent out of text file
old_links = File.readlines(File.dirname(__FILE__) + "/links.txt")

mechanize = Mechanize.new
# use machanize to get archives page content
page = mechanize.get("http://daniel.industries/archives")
# get all the links in the page with the class 'archive_link'
link = page.links_with(class: "archive_link").sample
# make sure it's a new one (not listed in links.txt)
while old_links.include? link.href
  link = page.links_with(class: "archive_link").sample
end
# get the href of the link
link_href = link.href
# get the text of the link
# link_text = link.text
# create a new html string for the link
puts "http://daniel.industries" + link_href
# add the new link to the list in links.txt
File.open(File.dirname(__FILE__) + "/links.txt", "a+") { |f|
  f.puts(link_href + "\n")
}

# check links on that page
link_check_page = mechanize.get("http://daniel.industries" + link_href)
links = link_check_page.links

# create a new checker instance
checker = LinkChecker::Typhoeus::Hydra::Checker.new

links.each do |link|
  checker.check link.href if link.href.start_with?("http")
end

# run the checks
checker.run
checker.results.each_pair do |bucket, results|
  puts "#{bucket}: #{results.size}"
  # if bucket == :error || bucket == :failure
  results.each do |result|
    puts "URL: #{result.result_uri}"
  end
  # end
end
