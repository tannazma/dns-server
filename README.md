# Simple DNS Server in Ruby

## Overview

This project implements a basic DNS server using Ruby. The server listens for DNS queries on port 53 and responds with a fixed DNS response. This implementation is intended as a starting point for understanding and building DNS server functionality in Ruby.

## Features

- Listens for DNS queries over UDP on port 53.
- Responds to received queries with a hardcoded DNS response.
- Prints received messages and responses in hexadecimal format for debugging and verification.

## Prerequisites

- Ruby (version 2.5 or later)
- `xxd` utility (commonly available on Unix-like systems)

## Installation

1. **Clone the repository**:

    ```sh
    git clone https://github.com/yourusername/simple-dns-server.git
    cd simple-dns-server
    ```

2. **Install required Ruby gems** (if any):

    This project does not have external gem dependencies, but ensure you have the `socket` and `open3` libraries available in your Ruby environment.

## Usage

1. **Run the DNS server on mac**:

    Run the DNS server with root privileges:

    Since macOS restricts binding to privileged ports (below 1024), you'll need to run the script with sudo:

    ```sh
    sudo ./dns_server.rb
    ```
    Ensure the script has executable permissions:

    ```sh
    chmod +x dns_server.rb
    ```
 **Verify the server is running**:
    The server will start listening for DNS queries on port 53. You can test it using dig or another DNS query tool:

    ```sh
    dig @localhost example.com
    ```
    The server will print the received query and the response in hexadecimal format.

    Alternative for non-root users:

    If you do not want to run the script as root, you can bind the server to a higher, non-privileged port (e.g., 8053). Edit the script to:

    ```sh
    socket.bind('::', 8053)
    ```
    Then test with:

    ```sh
    dig @localhost -p 8053 example.com
    ```

2. **Run the DNS server in Debian (Linux)**:
    ```sh
    ./dns_server.rb
    ```

    Ensure the script has executable permissions:

    ```sh
    chmod +x dns_server.rb
    ```

 **Verify the server is running**:

    The server will start listening for DNS queries on port 53. You can test it using `dig` or another DNS query tool:

    ```sh
    dig @localhost example.com
    ```

    The server will print the received query and the response in hexadecimal format.

## Code Explanation

### Main Components

1. **Constants and Socket Initialization**:
    - `MAX_UDP_LENGTH = 4096`: Maximum length of a UDP packet.
    - `socket = UDPSocket.new :INET6`: Creates a new UDP socket for IPv6.
    - `socket.bind('::', 53)`: Binds the socket to all available interfaces on port 53.

2. **Reply Function**:
    - `def reply_to(query)`: Method to generate a DNS response.
    - `id = query[0..1]`: Extracts the ID from the DNS query.
    - Returns a hardcoded DNS response.

3. **Main Loop**:
    - `while true`: Infinite loop to keep the server running.
    - `message, client = socket.recvfrom(MAX_UDP_LENGTH)`: Receives a DNS query.
    - Prints the received message in hexadecimal format using `xxd`.
    - Generates a response and prints it in hexadecimal format.
    - Sends the response back to the client.

### Example Code Snippet

```ruby
#!/usr/bin/env ruby

require 'socket'
require 'open3'

MAX_UDP_LENGTH = 4096

socket = UDPSocket.new :INET6
socket.bind('::', 53)

def reply_to(query)
  id = query[0..1]

  ## TODO: replace me with actual DNS implementation
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
```

## Future Improvements

- Implement a full DNS query parser and response generator.
- Add support for different DNS record types.
- Improve error handling and logging.
- Enhance security features to mitigate DNS-related attacks.

## References

- [RFC 1035 - Domain Names - Implementation and Specification](https://datatracker.ietf.org/doc/html/rfc1035)

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

---

Feel free to contribute to this project by opening issues or submitting pull requests. Your feedback and improvements are welcome!

---

*Note: Replace placeholder links with actual links and update the repository URL as needed.*