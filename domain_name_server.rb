#The script sets up a UDP server that listens for DNS queries on port 53.
#When a query is received, it prints the query in a human-readable format (hex dump).
#It generates a fixed DNS response (as a placeholder) and sends it back to the client.
#This loop continues indefinitely, handling incoming DNS queries

#!/usr/bin/env ruby

#This is a shebang line that tells the system to run this script using the Ruby interpreter.
#socket library is necessary for network communication
#open3 library which allows you to run external commands and capture their output.
require 'socket'
require 'open3'

MAX_UDP_LENGTH = 4096
#This sets the maximum length of a UDP packet that the server will handle

socket = UDPSocket.new :INET6
#This creates a new UDP socket that can handle IPv6 addresses
socket.bind('::', 53)
#This binds the socket to all available interfaces (:: for IPv6) on port 53, the standard DNS port.

def reply_to(query)
  id = query[0..1]

  ## TODO: replace me with actual DNS implementation
  # See https://datatracker.ietf.org/doc/html/rfc1035


  #To Implement a Real DNS Server, You would need to replace the reply_to method with code that can parse the DNS query and generate a valid DNS response. 
  #This would involve understanding the DNS protocol as described in RFC 1035.
  
  return id + "\x81\xa0\x00\x01" \
"\x00\x01\x00\x00\x00\x01\x07\x65\x78\x61\x6d\x70\x6c\x65\x03\x63" \
"\x6f\x6d\x00\x00\x01\x00\x01\xc0\x0c\x00\x01\x00\x01\x00\x00\x0a" \
"\x3f\x00\x04\x5d\xb8\xd7\x0e\x00\x00\x29\x04\xd0\x00\x00\x00\x00" \
"\x00\x00".b

end

while true
  #This receives a UDP packet from the socket. message is the content of the packet,
  #and client contains information about the sender and The received message is printed in a hexadecimal format using the xxd command.

  message, client = socket.recvfrom(MAX_UDP_LENGTH)

  puts 'Received:'
  hexdump, _status = Open3.capture2('xxd', stdin_data: message)
  puts hexdump
  puts

  response = reply_to(message)
  #This calls the reply_to method to generate a response to the received message.

  #If there is no response, it prints a message and continues to the next iteration of the loop.
  #The response is printed in hexadecimal format using the xxd command.

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

  #This sends the response back to the client. client[3] is the IP address of the client, and client[1] is the port number.
  socket.send(response, 0, client[3], client[1])
end