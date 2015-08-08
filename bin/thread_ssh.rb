#!/usr/bin/ruby
require 'net/ssh'

def func1
  i=0
  while i<=2
    ssh(__method__)
    sleep(2)
    i=i+1
  end
end

def func2
  j=0
  while j<=2
    ssh(__method__)
    sleep(1)
    j=j+1
  end
end

def ssh(label)
  ssh = Net::SSH.start('localhost', ENV['USER'])
  output = ssh.exec!('date')
  puts "[#{label}] [output=#{output.rstrip}]"
end

puts "Started At #{Time.now}"
t1=Thread.new{func1()}
t2=Thread.new{func2()}
t1.join
t2.join
puts "End at #{Time.now}"