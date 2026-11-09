require "minitest/autorun"
require "nokogiri"
require_relative "../wayback_archive"

class WaybackArchiveTest < Minitest::Test
  Response = Struct.new(:body, :ok) do
    def success? = ok
  end

  def test_post_date_comes_from_page_url_or_metadata
    doc = Nokogiri::HTML('<meta property="article:published_time" content="2020-01-02T12:00:00Z">')

    assert_equal Date.new(2002, 9, 9), WaybackArchive.post_date("https://example.com/2002/09/09/post.html", doc)
    assert_equal Date.new(2020, 1, 2), WaybackArchive.post_date(nil, doc)
  end

  def test_chooses_successful_capture_closest_to_post_date
    requests = []
    query = lambda do |url, range|
      requests << [url, range]
      timestamp = range.key?("to") ? "20020101000000" : "20020111000000"
      [timestamp, "http://example.com/post?q=1"]
    end

    with_query(query) do
      assert_equal "https://web.archive.org/web/20020111000000/http://example.com/post?q=1",
        WaybackArchive.find("http://example.com/post?q=1", Date.new(2002, 1, 10))
    end

    assert_equal 2, requests.length, requests.inspect
    assert_equal ["20020110", "20020110"], [requests[0][1]["to"], requests[1][1]["from"]]
    assert requests.all? { |url, _range| url == "http://example.com/post?q=1" }
  end

  def test_missing_or_failed_cdx_response_has_no_archive
    with_query(->(_url, _range) { nil }) do
      assert_nil WaybackArchive.find("https://example.com", Date.new(2020, 1, 1))
      assert_nil WaybackArchive.find("https://example.com", nil)
    end
  end

  def test_cdx_query_encodes_url_and_reads_timestamp_and_original
    request_url = nil
    original_get = Typhoeus.method(:get)
    Typhoeus.define_singleton_method(:get) do |url, **_options|
      request_url = url
      Response.new('[["timestamp","original"],["20200103120000","http://example.com/?a=1&b=2"]]', true)
    end

    assert_equal ["20200103120000", "http://example.com/?a=1&b=2"],
      WaybackArchive.send(:query, "http://example.com/?a=1&b=2", "from" => "20200102", "limit" => 1)
    params = URI.decode_www_form(URI.parse(request_url).query).to_h
    assert_equal "http://example.com/?a=1&b=2", params["url"]
    assert_equal "statuscode:200", params["filter"]
    assert_equal "20200102", params["from"]
  ensure
    Typhoeus.define_singleton_method(:get, original_get)
  end

  private

  def with_query(replacement)
    original = WaybackArchive.method(:query)
    WaybackArchive.define_singleton_method(:query, replacement)
    yield
  ensure
    WaybackArchive.define_singleton_method(:query, original)
    WaybackArchive.singleton_class.send(:private, :query)
  end
end
