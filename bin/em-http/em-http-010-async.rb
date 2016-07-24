require 'eventmachine'
require 'em-http-request'
require 'logger'
require 'pry'


##
# concurrent requests without concurrency limits

@request_queue = []
@start_time = Time.now
@logger = Logger.new($stdout)

def runtime
  Time.now - @start_time
end

def new_http_request(url)
  request_hash = {}
  @request_queue << request_hash
  http = EventMachine::HttpRequest.new(url).get
  request_hash[:http] = http
  finish = lambda do |http|
    request_hash[:response] = http.response
    status_code = http.response_header.status
    @logger.debug("[#{__method__}] [url=#{url}] [CALLBACK/ERRBACK #{status_code}] [runtime=#{runtime}]")
    stop_when_all_finished
  end
  http.callback(&finish)
  http.errback(&finish)
end

def stop_when_all_finished
  @logger.debug("[#{__method__}] [states=#{@request_queue.map {|r| r[:http].state}}]")
  EM.stop if @request_queue.all? {|r| r[:http].state.eql?(:finished)}
end

EventMachine.run {
  new_http_request('http://ipv4.download.thinkbroadband.com/5MB.zip')
  new_http_request('http://ipv4.download.thinkbroadband.com/10MB.zip')
}

binding.pry
