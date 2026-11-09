require "date"
require "json"
require "typhoeus"
require "uri"

module WaybackArchive
  CDX_URL = "https://web.archive.org/cdx/search/cdx"

  def self.post_date(page_url, doc = nil)
    path = URI.parse(page_url).path if page_url
    if path && (match = path.match(%r{/(\d{4})/(\d{2})/(\d{2})/}))
      return Date.new(*match.captures.map(&:to_i))
    end

    published = doc&.at_css('meta[property="article:published_time"]')&.[]("content") ||
      doc&.at_css("article time[datetime], time[datetime]")&.[]("datetime")
    Date.parse(published) if published
  rescue ArgumentError, URI::InvalidURIError
    nil
  end

  def self.find(url, date)
    captures = if date
      day = date.strftime("%Y%m%d")
      [query(url, "to" => day, "limit" => -1),
       query(url, "from" => day, "limit" => 1)].compact
    else
      [query(url, "limit" => -1)].compact
    end
    return nil if captures.empty?

    capture = if date
      captures.min_by { |timestamp, _| (Date.strptime(timestamp[0, 8], "%Y%m%d") - date).abs }
    else
      captures.first
    end
    "https://web.archive.org/web/#{capture[0]}/#{capture[1]}"
  end

  def self.query(url, range)
    params = { "url" => url, "output" => "json", "fl" => "timestamp,original",
               "filter" => "statuscode:200" }.merge(range)
    response = Typhoeus.get("#{CDX_URL}?#{URI.encode_www_form(params)}", timeout: 10)
    return nil unless response.success?

    rows = JSON.parse(response.body)
    return nil unless rows.is_a?(Array) && rows.first == %w[timestamp original]

    timestamp, original = rows[1]
    return nil unless timestamp&.match?(/\A\d{14}\z/) && original&.match?(%r{\Ahttps?://})

    [timestamp, original]
  rescue JSON::ParserError
    nil
  end
  private_class_method :query
end
