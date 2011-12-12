#!/usr/bin/env ruby

require 'dnssd'
require 'socket'

browser = DNSSD::Service.new

puts "Browsing for Agent service"

Thread.new do
  browser.browse '_udisks-ssh._tcp' do |reply|
    Thread.new do
      Thread.exclusive do
        puts "Time: #{Time.new.to_f} reply: #{reply.fullname}"
        puts reply.inspect
        puts "service_name: #{reply.service_name}"

        target = nil
        resolver = DNSSD::Service.new

        resolver.resolve reply do |r|
          target = r.target
          puts "#{r.name} on #{r.target}:#{r.port}"
          p r
          puts "\t#{r.text_record.inspect}" unless r.text_record.empty?
          break unless r.flags.more_coming?
        end

        puts "resolver..."

        p resolver

        #resolver.stop

        puts "target: #{target}"
        addrinfo = Socket.getaddrinfo target, nil, Socket::AF_INET

        puts "Addresses for #{target}"
        addrinfo.each do |addr|
          puts addr.inspect
        end

        puts "-----"
        break
      end
    end
  end
end

sleep 1
