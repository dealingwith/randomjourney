require "typhoeus"
require "ruby-link-checker" # https://github.com/dblock/ruby-link-checker/
require "optparse"
require "nokogiri"
require "open-uri"
require "amazing_print"

# Parse command line options
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: link_check.rb [options]"

  opts.on("-f", "--file FILENAME", "File containing URLs to check") do |filename|
    options[:filename] = filename
  end
  opts.on("-u", "--url URL", "URL to check") do |url|
    options[:url] = url
  end
end.parse!

# Ensure a filename is provided
if options[:filename].nil? && options[:url].nil?
  puts "Please provide a filename using the -f option or a URL using the -u option."
  exit
end

# Read the entire file content or fetch the HTML content from the URL
file_content = options[:filename] ? File.read(options[:filename]) : URI.open(options[:url]).read

# Parse the content as HTML
doc = Nokogiri::HTML(file_content)

# Extract URLs from link tags
links = doc.css("a").map { |link| link["href"] }.compact

# create a new checker instance
checker = LinkChecker::Typhoeus::Hydra::Checker.new

links.each do |url|
  checker.check url if url.start_with?("http")
end

# run the checks
checker.run

# display buckets of results
checker.results.each_pair do |bucket, results|
  puts "#{bucket}: #{results.size}"
  if bucket == :error || bucket == :failure
    results.each do |result|
      puts "URL: #{result.result_uri}"
    end
  end
end
