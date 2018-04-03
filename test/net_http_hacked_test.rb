require "test_helper"
require "net_http_hacked"

class NetHttpHackedTest < Test::Unit::TestCase
  
  def test_net_http_hacked
    req = Net::HTTP::Get.new("/")
    http = Net::HTTP.start("www.example.com", "80")
    
    # Response code
    res = http.begin_request_hacked(req)
    assert_equal "200", res.code
    
    # Headers
    headers = {}
    res.each_header { |k, v| headers[k] = v }

    assert headers.size > 0
    assert_equal "text/html", headers["content-type"]
    assert !headers["date"].nil?
    
    # Body
    chunks = []
    res.read_body do |chunk|
      chunks << chunk
    end
    
    assert chunks.size > 0
    chunks.each do |chunk|
      assert chunk.is_a?(String)
    end
    
    http.end_request_hacked
  end
  
end
