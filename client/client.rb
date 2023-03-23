require "dnsruby"
require "base32"
require_relative "helpers/proxy"
require_relative  "helpers/dns_parser"

# WARNING! before launching, dont forget to disable systemd-resolved service and change the default dns server 

#struct
# the struct max size is 500, because -> A domain can have up to 500 subdomains
# (end? -> 1 true, 0 false).(packet_order_id).(size).(base64_encoded_payload).dnsruby.tun

# while !end && recv_size != size

DOMAIN = "dnsruby.tun"
MAX_CHUNK_SIZE = 30

class ClientProxy

	def initialize(nameserver, proxy_port)
		@resolver = Dnsruby::Resolver.new
		@dns_parser = DNSParser.new
		@resolver.use_tcp = true
		@resolver.nameservers = [nameserver] #our own dns server

		handler = proc do |req, res| #interception handler
		
			if req[1]["method"] == "CONNECT"

				# HTTPS Is not implemented yet!

			else
				p req[0]
				encoded = Base32.encode32(req[0])
				chunks = get_chunks(encoded, MAX_CHUNK_SIZE)
				response = send_chunks(chunks)
				res.print(response) if response
				res.close
			
			end

		end

		@proxy = Proxy.new(proxy_port, handler)
		@proxy.start
	end

	def get_chunks(string, size) # chunks helper function
		string.unpack("a#{size}" * (string.size/size.to_f).ceil)
	end
	
	def send_chunks(chunks)
		unique_id = Random.rand(100..500).to_s
		chunks.each.with_index do |chunk, id|

			query_domain = "#{id.to_i == (chunks.size - 1) ? 1 : 0}.#{id}.#{unique_id}.#{chunks.join.size}.#{chunk}.#{DOMAIN}"
			begin

			query = @resolver.query(query_domain, "TXT")
			@dns_parser.parse(query.answer) # parse each chunk received from dns server
			rescue 
				puts "Error occured, probably timeout"
				puts "-"*30
				p "#{chunks.join}"
				puts "-"*30
			end
			
			if @dns_parser.is_readable? # if all chunks are received
				packets = @dns_parser.get_packets().join()

				puts "SIZE RECV: #{packets.size}"
				p Base32.decode32( packets )
				@dns_parser.cleanup
				return Base32.decode32(packets)
			end

			
		end

		return nil
		
	end

end


p = ClientProxy.new("127.0.0.1", 8000)

 







