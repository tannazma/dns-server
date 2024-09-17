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

class DNSHeader
  attr_reader :id, :flags, :num_questions, :num_answers, :num_auth, :num_additional
  
  def initialize(buf)
    hdr = buf.read(12)
    @id, @flags, @num_questions, @num_answers, @num_auth, @num_additional = hdr.unpack('nnnnnn')
  end
end

class DNSQuestion
  attr_reader :qname, :qtype, :qclass

  def initialize(buf)
    @qname = parse_name(buf) # Parse domain name
    @qtype = buf.read(2).unpack('n').first # Type (e.g., A, MX)
    @qclass = buf.read(2).unpack('n').first # Class (usually IN for Internet)
  end

  def parse_name(buf)
    name = []
    while (len = buf.read(1).unpack('C').first) > 0
      name << buf.read(len)
    end
    name.join(".")
  end
end

class DNSResponse
  def initialize(id, question)
    @id = id
    @question = question
    @answers = []
  end

  def build_response
    header = [@id, 0x8180, 1, 1, 0, 0].pack('n*').force_encoding('ASCII-8BIT') # Standard response header
    question = build_question_section.force_encoding('ASCII-8BIT')
    answer = build_answer_section.force_encoding('ASCII-8BIT')
    (header + question + answer).force_encoding('ASCII-8BIT') # Ensure the whole packet is ASCII-8BIT
  end

  def build_question_section
    qname = @question.qname.split(".").map { |part| [part.length, part].pack('Ca*') }.join.force_encoding('ASCII-8BIT') + "\0".force_encoding('ASCII-8BIT')
    qtype = [@question.qtype].pack('n').force_encoding('ASCII-8BIT')
    qclass = [@question.qclass].pack('n').force_encoding('ASCII-8BIT')
    qname + qtype + qclass
  end

  def build_answer_section
    # Example response for an A record (IPv4 address)
    ttl = [3600].pack('N').force_encoding('ASCII-8BIT') # Time to live
    rdata = [127, 0, 0, 1].pack('C4').force_encoding('ASCII-8BIT') # Example IP (localhost)
    rname = "\xc0\x0c".force_encoding('ASCII-8BIT') # Pointer to domain name in question
    rtype = [1].pack('n').force_encoding('ASCII-8BIT') # A record
    rclass = [1].pack('n').force_encoding('ASCII-8BIT') # IN (Internet)
    rdlength = [rdata.length].pack('n').force_encoding('ASCII-8BIT')
    rname + rtype + rclass + ttl + rdlength + rdata
  end
end

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