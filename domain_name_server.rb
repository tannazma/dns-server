#!/usr/bin/env ruby

require 'socket'
require 'open3'

MAX_UDP_LENGTH = 4096

socket = UDPSocket.new :INET6
socket.bind('::', 53)

def reply_to(query)
  id = query[0..1]

  ## TODO: replace me with actual DNS implementation
  # See https://datatracker.ietf.org/doc/html/rfc1035
  return id + "\x81\xa0\x00\x01" \
"\x00\x01\x00\x00\x00\x01\x07\x65\x78\x61\x6d\x70\x6c\x65\x03\x63" \
"\x6f\x6d\x00\x00\x01\x00\x01\xc0\x0c\x00\x01\x00\x01\x00\x00\x0a" \
"\x3f\x00\x04\x5d\xb8\xd7\x0e\x00\x00\x29\x04\xd0\x00\x00\x00\x00" \
"\x00\x00".b

end

while true
  message, client = socket.recvfrom(MAX_UDP_LENGTH)

  puts 'Received:'
  hexdump, _status = Open3.capture2('xxd', stdin_data: message)
  puts hexdump
  puts

  response = reply_to(message)

  if response.nil?
    puts 'No response sent'
    puts '----------'
    puts
    next
  end

  puts 'Replying with:'
  hexdump, _status = Open3.capture2('xxd', stdin_data: response)
  puts hexdump
  puts '----------'
  puts

  socket.send(response, 0, client[3], client[1])
end