#!/usr/bin/ruby

class NotAnIPError < Exception
	def initialize(not_an_ip)
		super("#{not_an_ip.inspect} isn't a valid IP address")
	end
end

# This class represents an IP address.
class IPAddress
	class << self
		# Is _addr_ an IP address?
		def is_an_ip?(addr)
			%w{
					is_an_ip_instance? is_a_string_ip? is_an_array_ip?
			    is_an_integer_ip?
			  }.each do |m|
					return true if send(m, addr)
				end

			false
		end

		def is_an_ip_instance?(addr)
			addr.is_a?(IPAddress)
		end

		# Is _addr_ a string representation of an IP (without a netmask)?
		def is_a_string_ip?(addr)
			addr, mask = /^(\d+(?:\.\d+){3})(?:\/(\d+))?$/.match(addr).captures

			# nil.to_i is 0.
			return false unless (0..32) === mask.to_i

			is_an_array_ip?( addr.split(".").map{|x| x.to_i} )
		end

		# Is this an array representation of an IP?
		def is_an_array_ip?(addr)
			addr.length == 4 and addr.all?{|a| (0..255).include?(a)}
		end

		# Is _addr_ and integer representation of an IP?
		def is_an_integer_ip?(addr)
			addr.integer? and (0 ... 256**4).include?(addr)
		end

		%w{
			is_an_ip_instance? is_a_string_ip? is_an_array_ip? is_an_integer_ip?
		}.each do |meth_name|
			_m = instance_method(meth_name)
			define_method(meth_name){ |*a,&b|
				_m.bind(self).(*a, &b) rescue false
			}
		end
	end

	# our netmask
	attr_reader :netmask

	# Set our netmask to _val_.
	def netmask=(val)
		@ip = mask(@ip, val)
		@netmask = val
	end

	# @overload new(ip)
	#  @param [String] ip an IP like "12.4.97.8"
	# @overload new(ip)
	#  @param [String] ip an IP like "12.4.97.0/24"
	# @overload new(ip)
	#  @param [String] ip an IP like [12, 4, 97, 8]
	# @overload new(ip)
	#  @param [IPAddress] ip another IPAddress instance
	# @overload new(ip)
	#  @param [Fixnum] ip an IP like (12*256**3 + 4*256**2 + 97*256 + 8)
	def initialize(ip)
		@ip, nmask = any_to_int_and_netmask(ip)

		self.netmask = nmask
	end

	# Get our _indx_th quad.
	# @example
	#  IPAddress.new("12.4.97.8")[1] #=> 4
	def [](index)
		unless (0..3) === index
			raise ArgumentError, "there are four parts to an IP address"
		end

		to_a[index]
	end

	# Set our _index_th quad to the integer _val_.
	# @example
	#  ip = IPAddress.new("12.4.97.0")
	#  ip[3] = 8
	#  ip #=> #<IPAddress: 12.4.97.8>
	def []=(index, val)
		if !((0..3) === index)
			raise ArgumentError, "there are four parts to an IP address"
		elsif !((0..256) === val)
			raise ArgumentError, "each of the IP parts is between 0 and 256"
		end

		ip_as_array = to_a
		ip_as_array[index] = val
		@ip, @netmask = any_to_int_and_netmask(ip_as_array)

		val
	end

	# our quads
	def to_a
		int_to_array(@ip)
	end

	def to_s
		to_a.join(".") + (@netmask == 32 ? "" : "/#{@netmask}")
	end

	def to_i
		@ip
	end

	def inspect
		"#<#{self.class}: #{self}>"
	end

	# Return a new IPAddress instance with a netmask of _nmask_ with an IP the
	# same as ours.
	# @example
	#  ip = IPAddress.new("12.4.97.8") / 24 #=> #<IPAddress: 12.4.97.0/24>
	def /(nmask)
		self.class.new(self).tap{|x| x.netmask = nmask}
	end

	def ==(ip)
		return false unless self.class.is_an_ip?(ip)
		ip = self.class.new(ip) unless ip.is_a? self.class

		ip.to_i == to_i and ip.netmask == @netmask
	end

	# Is _ip_ in our IP range?
	def ===(ip)
		self == ( self.class.new(ip) / @netmask )
	end

	private
	def mask(ip_int, nmask)
		(ip_int >> (32 - nmask)) << (32 - nmask)
	end

	# Convert an IP address of any of the forms supported by IPAddress#new() to a
	# Fixnum (also described there) and a netmask.
	# @return [Fixnum, Fixnum] something like [201613576, 32]
	def any_to_int_and_netmask(ip)
		if self.class.is_a_string_ip?(ip)
			if ip =~ /^(.+)\/(.+)$/
				ip, mask = $1, $2.to_i
			else
				mask = 32
			end

			quads = ip.split('.').map{|q| q.to_i}
			return [array_to_int(quads), mask]

		elsif self.class.is_an_array_ip?(ip)
			return array_to_int(ip), 32

		elsif self.class.is_an_integer_ip?(ip)
			return ip, 32

		elsif self.class.is_an_ip_instance?(ip)
			return ip.to_i, ip.netmask

		else
			raise NotAnIPError.new(ip)
		end
	end

	# Turn an Array representation of an IP address _array_ to an equivalent
	# Fixnum representation.
	# @param [Array] array an Array like [12, 4, 97, 8]
	# @return [Fixnum] array.reduce{ |x, y| x*256 + y }
	def array_to_int(array)
		unless array.all?{ |i| (0..256) === i } and array.length == 4
			raise NotAnIPError.new(array)
		end

		return array.reduce{ |x, y| x*256 + y }
	end

	# Turn a Fixnum representation of an IP address _ip_int_ to its Array
	# equivalent.
	# @param [Fixnum] ip_int something like 201613576
	# @return [Array] something like [12, 4, 97, 8]
	def int_to_array(ip_int)
		ip_array = Array.new

		4.times do
			ip_array.unshift( ip_int % 256 )
			ip_int /= 256
		end

		ip_array
	end
end
