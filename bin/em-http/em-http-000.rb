require 'eventmachine'
require 'em-http-request'
require 'logger'

##
# Single request

@start_time = Time.now
@logger = Logger.new($stdout)

EventMachine.run {
  url = 'http://ipv4.download.thinkbroadband.com/5MB.zip'
  http = EventMachine::HttpRequest.new(url).get
  http.callback do |http|
    @logger.debug("[#{__method__}] [url=#{url}] [CALLBACK] [runtime=#{@start_time - Time.now}]")
    p http.response_header.status
    p http.response_header
    EM.stop
  end
  http.errback do |errback|
    @logger.debug("[#{__method__}] [url=#{url}] [ERRBACK] [runtime=#{@start_time - Time.now}]")
    EM.stop
  end
}
