require "mechanize"

url = ARGV[0]

mechanize = Mechanize.new

page = mechanize.get(url)
article = page.at("article")

# page.links.each do |link|
#   # todo: check link
#   puts link.href
# end
if article
  article.css("a[href]").each do |link|
    puts link["href"]
  end
end
