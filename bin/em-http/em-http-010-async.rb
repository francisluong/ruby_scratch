require 'eventmachine'
require 'em-http-request'
require 'logger'
require 'pry'


##
# concurrent requests without concurrency limits

FIVE = 'http://ipv4.download.thinkbroadband.com/5MB.zip'
TEN  = 'http://ipv4.download.thinkbroadband.com/10MB.zip'

@request_queue = []
@start_time = Time.now
@logger = Logger.new($stdout)

def runtime
  Time.now - @start_time
end

def new_http_request(url)
  # every job gets added to the +@request_queue+
  request_hash = {}
  @request_queue << request_hash
  http = EventMachine::HttpRequest.new(url).get
  @logger.debug("[#{__method__}] [url=#{url}] [SUBMITTED] [runtime=#{runtime}]")
  request_hash[:http] = http
  # create an anonymous function and bind it to both callback and errback
  finish = lambda do |http|
    request_hash[:response] = http.response
    status_code = http.response_header.status
    @logger.debug("[#{__method__}] [url=#{url}] [CALLBACK/ERRBACK #{status_code}] [runtime=#{runtime}]")
    # instead of issuing an EM.stop after each job,
    # ...we need to wait for all jobs in +@request_queue+ to finish before we stop
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

EventMachine.run {
  new_http_request(FIVE)
  new_http_request(TEN)
}

binding.pry
