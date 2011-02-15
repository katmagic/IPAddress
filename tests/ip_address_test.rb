#!/usr/bin/ruby
require 'test/unit'
require_relative '../lib/ip_address.rb'

class IPAddressTest < Test::Unit::TestCase
	def test_validity
		%w{ tgklmrok gk95*!) 256.1.9.5 1.2.5.4. &&&~ 1.2.3.555 1.2..5 }.each do |ip|
			s = "#{ip} isn't a valid IP"
			assert(!IPAddress.is_an_ip?(ip), s)
			assert_raise(NotAnIPError, s){ IPAddress.new(ip) }
		end

		%w{ 1.2.3.4 0.0.0.0 11.51.15.11 255.255.255.255 17.214.51.99 }.each do |ip|
			s = lambda{|ip|"#{ip} is a valid IP"}
			assert(IPAddress.is_an_ip?(ip), s[ip])
			assert_nothing_raised(s[ip]){ IPAddress.new(ip) }
		end
	end

	EQUAL_IPS = {
		"1.2.3.4" => "1.2.3.4/32",
		"1.2.3.0/24" => "1.2.3.4/24",
		"0.0.0.0/0" => "5.1.5.6/0",
		"0.0.0.0/8" => "0.0.0.0/8",
		"1.2.3.4" => 16909060,
		1291977476 => "77.2.3.4",
		[1, 2, 3, 4] => "1.2.3.4",
		[5, 6, 7, 8] => [5, 6, 7, 8]
	}
	NOT_EQUAL_IPS = {
		"0.0.0.0/8" => "0.0.0.0",
		"1.2.3.4" => "5.6.7.8",
		11 => 156,
		[0, 0, 5, 10] => 510,
		19 => "2.4.6.8",
		"1.2.3.0/8" => "2.2.3.0/8"
	}
	def test_equality
		%w{equal not_equal}.each do |equality_type|
			assert_ = method("assert_#{equality_type}")

			self.class.const_get("#{equality_type.upcase}_IPS").each do |a, b|
				ip_a = IPAddress.new(a)
				ip_b = IPAddress.new(b)
				assert_.(ip_a, ip_b, "#{a} and #{b} are #{equality_type}")
			end
		end
	end
end
