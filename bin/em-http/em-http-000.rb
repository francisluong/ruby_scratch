require 'eventmachine'
require 'em-http-request'
require 'logger'
require 'pry'

##
# Single request

@start_time = Time.now
@logger = Logger.new($stdout)
http = nil
status_code = nil

def runtime
  Time.now - @start_time
end

EventMachine.run {
  url = 'http://ipv4.download.thinkbroadband.com/5MB.zip'
  # Create HTTP Request and issue get, which returns an HTTPConnection
  http = EventMachine::HttpRequest.new(url).get
  @logger.debug("[#{__method__}] [url=#{url}] [SUBMITTED] [runtime=#{runtime}]")
  # setup callbacks and errbacks to deal with normal and errored completion
  http.callback do
    status_code = http.response_header.status
    @logger.debug("[#{__method__}] [url=#{url}] [CALLBACK #{status_code}] [runtime=#{runtime}]")
    p http.response_header
    EM.stop
  end
  http.errback do
    status_code = http.response_header.status
    @logger.debug("[#{__method__}] [url=#{url}] [ERRBACK #{status_code}] [runtime=#{runtime}]")
    p http.response_header
    EM.stop
  end
}

# lauch Pry in case we want to do any REPL-y things
binding.pry
