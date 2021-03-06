Gem::Specification.new do |s|
	s.name = 'ip_address'
	s.version = '0.1.2'
	s.date = Time.now.strftime("%a %b %d, %Y")
	s.summary = 'Work with IP addresses.'
	s.description = 'Easily manipulate IPv4 addresses.'
	s.author = 'katmagic'
	s.email = 'the.magical.kat@gmail.com'
	s.homepage = 'https://github.com/katmagic/IPAddress'
	s.rubyforge_project = 'ip_address'
	s.license = 'Unlicense (http://unlicense.org)'
	s.files = 'lib/ip_address.rb'

	if ENV['GEM_SIG_KEY']
		s.signing_key = ENV['GEM_SIG_KEY']
		s.cert_chain = ENV['GEM_CERT_CHAIN'].split(",") if ENV['GEM_CERT_CHAIN']
	else
		warn "environment variable $GEM_SIG_KEY unspecified; not signing gem"
	end
end
