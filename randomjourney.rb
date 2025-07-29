require "mechanize"
require "typhoeus"
require "ruby-link-checker" # https://github.com/dblock/ruby-link-checker/

# Get URL fragment from command line argument if provided
url_fragment = ARGV[0]

# read file of links already sent out of text file
old_links = File.readlines(File.dirname(__FILE__) + "/links.txt")

mechanize = Mechanize.new

if url_fragment
  # Use specified URL fragment
  link_href = url_fragment
  puts "Using specified URL fragment: #{url_fragment}"
else
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
end
# get the text of the link
# link_text = link.text
# create a new html string for the link
puts "http://daniel.industries" + link_href
# add the new link to the list in links.txt (if it's not already there)
unless old_links.include?(link_href)
  File.open(File.dirname(__FILE__) + "/links.txt", "a+") { |f|
    f.puts(link_href + "\n")
  }
end

# check links on that page
link_check_page = mechanize.get("http://daniel.industries" + link_href)
links = link_check_page.links

# create a new checker instance
checker = LinkChecker::Typhoeus::Hydra::Checker.new

links.each do |link|
  checker.check link.href if link&.href&.start_with?("http")
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
