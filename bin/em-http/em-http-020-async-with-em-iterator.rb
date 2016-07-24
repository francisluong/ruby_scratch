require 'eventmachine'
require 'em-http-request'
require 'logger'
require 'pry'

##
# concurrent requests with EM::Iterator concurrency limit of 2

FIVE = 'http://ipv4.download.thinkbroadband.com/5MB.zip'
TEN  = 'http://ipv4.download.thinkbroadband.com/10MB.zip'

@request_queue = []
@start_time = Time.now
@logger = Logger.new($stdout)

def runtime
  Time.now - @start_time
end

def new_http_request(request_hash, &block)
  @request_queue << request_hash
  url = request_hash[:url]
  # Submit HTTP Request
  http = EventMachine::HttpRequest.new(url).get
  @logger.debug("[#{__method__}] [url=#{url}] [SUBMITTED] [runtime=#{runtime}]")
  request_hash[:http] = http
  # Bind Callback/Errback to this anonymou7s function
  finish = lambda do |this_http|
    request_hash[:response] = this_http.response
    request_hash[:response_code] = this_http.response_header.status
    @logger.debug("[#{__method__}] [url=#{url}] [CALLBACK/ERRBACK #{request_hash[:response_code]}] [runtime=#{runtime}]")
    # yield to the block, which will start the next job
    yield if block_given?
    # check to see if we can EM.stop
    stop_when_all_finished
  end
  http.callback(&finish)
  http.errback(&finish)
end

##
# Check states for all requests in +@request_queue+ and issue EM.stop if true
def stop_when_all_finished
  @logger.debug("[#{__method__}] [states=#{@request_queue.map {|r| r[:http].state}}]")
  EM.stop if @request_queue.all? {|r| r[:http].state.eql?(:finished)}
end

## --- MAIN

## These are the requests we will submit - six in total
my_requests = [
    {url: FIVE},
    {url: TEN},
    {url: FIVE},
    {url: TEN},
    {url: FIVE},
    {url: TEN},
]
concurrency_limit = 2

EventMachine.run {
  # use EM::Iterator to submit EM::HTTPRequests
  EM::Iterator.new(my_requests, concurrency_limit).each do |request_hash,iter|
    new_http_request(request_hash) { iter.next }
  end
}

binding.pry
