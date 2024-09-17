#!/usr/bin/env ruby

require 'socket'
require 'open3'

#The script sets up a UDP server that listens for DNS queries on port 53.
#When a query is received, it prints the query in a human-readable format (hex dump).
#It generates a fixed DNS response (as a placeholder) and sends it back to the client.
#This loop continues indefinitely, handling incoming DNS queries


#This is a shebang line that tells the system to run this script using the Ruby interpreter.
#socket library is necessary for network communication
#open3 library which allows you to run external commands and capture their output.

MAX_UDP_LENGTH = 4096
#This sets the maximum length of a UDP packet that the server will handle

socket = UDPSocket.new :INET6
#This creates a new UDP socket that can handle IPv6 addresses
socket.bind('::', 8053)
#This binds the socket to all available interfaces (:: for IPv6) on port 53, the standard DNS port.

def reply_to(query)
  buf = StringIO.new(query)
  
  # Parse the DNS header
  header = DNSHeader.new(buf)
  
  # Parse the DNS question section
  question = DNSQuestion.new(buf)
  
  # Create the DNS response
  response = DNSResponse.new(header.id, question)
  
  # Build the full DNS response packet
  return response.build_response
end

while true
  #This receives a UDP packet from the socket. message is the content of the packet,
  #and client contains information about the sender and The received message is printed in a hexadecimal format using the xxd command.

  message, client = socket.recvfrom(MAX_UDP_LENGTH)

  #hex dump represents a DNS response for an A record query for example.com, returning the IP address 93.184.216.14

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