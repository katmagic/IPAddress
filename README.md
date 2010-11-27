IPAddress
=========

Work with IPv4 addresses.

Installation
------------

	gem install ip_address

Usage
-----

#### Check the validity of a string representation of an IP.
	IPAddress.is_an_ip? "12.10.19.72" # true

#### Work with the quads of an IP.
	ip = IPAddress.new("12.10.19.72")
	ip[0] # 12
	ip[0] = 13
	ip # #<IPAddress: 13.10.19.72>

#### Work with netmasks.
	ip = IPAddress.new("4.7.2.3/16") # #<IPAddress: 4.7.0.0/16>
	ip == IPAddress.new("4.7.2.3")/16 # true
	ip[2] # 0
	ip.netmask = 8
	ip # #<IPAddress: 1.0.0.0/8>

#### Test equivalency.
	ip == "4.7.0.0/16" # true
	ip/32 == [4, 7, 0, 0] # true
