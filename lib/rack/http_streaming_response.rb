require "net_http_hacked"

module Rack

  # Wraps the hacked net/http in a Rack way.
  class HttpStreamingResponse
    attr_accessor :use_ssl, :verify_ssl, :timeout

    def initialize(request, host, port = nil)
      @request, @host, @port = request, host, port
    end
    
    def status
      response.code.to_i
    end
    
    def headers
      h = Utils::HeaderHash.new
      
      response.each_key do |k|
        values = response.get_fields(k)
        values = values.first if values.length == 1
        h[k] = values
      end
      
      h
    end
    
    def body
      self
    end

    # Can be called only once!
    def each(&block)
      response.read_body(&block)
    ensure
      session.end_request_hacked unless mocking?
    end
    
    def to_s
      @body ||= begin
        lines = []

        each do |line|
          lines << line
        end
        
        lines.join
      end
    end
    
    protected
    
    # Net::HTTPResponse
    def response
      if mocking?
        @response ||= session.request(@request)
      else
        @response ||= session.begin_request_hacked(@request)
      end
    end
    
    # Net::HTTP
    def session
      @session ||= begin
        http = Net::HTTP.new @host, @port
        http.use_ssl = self.use_ssl
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE if self.use_ssl && !self.verify_ssl.nil? && self.verify_ssl == false
        http.read_timeout = self.timeout unless self.timeout.nil?
        http.start
      end
    end

    def mocking?
      defined?(WebMock) || defined?(FakeWeb)
    end
    
  end

end
