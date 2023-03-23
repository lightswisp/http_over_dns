#!/usr/bin/ruby
require 'rubydns'
require 'base32'
require 'socket'
require_relative 'helpers/dns_parser'
require_relative 'helpers/sock_parser'
require_relative 'helpers/http'

include Sender



INTERFACES = [

	[:tcp, "0.0.0.0", 53],
]

MAX_TXT_CHUNK_SIZE = 255 

IN = Resolv::DNS::Resource::IN

# Use upstream DNS for name resolution.
UPSTREAM = RubyDNS::Resolver.new([[:tcp, "8.8.8.8", 53]])

class HTTP_Over_DNSProxy
	def initialize()
		
	end

	def self.send_transaction(transaction, data)
		# BASE32 ENCODING AND CHUNKING RESPONSE
		response_encoded = Base32.encode32(data)
		response_encoded_chunks = Sender.get_chunks(response_encoded, MAX_TXT_CHUNK_SIZE)
		
		response_encoded_chunks.each do |chunk|
			transaction.respond!(chunk)
		end

		puts
		puts "WHAT WAS SENT ACTUALLY"
		puts "SIZE SENT: #{response_encoded.size}"
		p "#{Base32.decode32(response_encoded)}"
		puts

		transaction.respond!("END")
	end

	def start()
		# Start the RubyDNS server
		RubyDNS::run_server(INTERFACES) do
			dns_parser = DNSParser.new
		
			match(/dnsruby.tun/, IN::TXT) do |transaction|
			
				ip_addr  = transaction.options[:remote_address].ip_address
				question = transaction.question.to_s
				question_parts = question.split(".")

				unique_id = dns_parser.parse(question_parts)
				is_readable_id = dns_parser.is_readable?(unique_id)
				
				if is_readable_id
					# GETTING REQUEST
					decoded = Base32.decode32(dns_parser.get_packets(unique_id).join()) 
					dns_parser.cleanup(unique_id)

					# PARSING AND SENDING REQUEST
					sock_parser = SockParser.new(decoded) 
					parsed_request = sock_parser.parse()

					if sock_parser.valid?
						puts "SIZE RECV: #{Base32.encode32(decoded).size}"
						host, port = parsed_request["host"], parsed_request["port"]


						if parsed_request["method"] == "CONNECT"
							# HTTPS IS NOT YET IMPLEMENTED
							
						else parsed_request["method"] && parsed_request["method"] != "CONNECT"

							# HTTP
							
							response = Sender.send_http(decoded, host, port)
							p "MUST BE SENT\n #{response}"
							HTTP_Over_DNSProxy.send_transaction(transaction, response)

							
						end
					end

				else
					transaction.respond!("NULL")
				end
				
		
				#puts "[*] #{ip_addr} => #{question}"
				

			
			end
		
			# Default DNS handler
			otherwise do |transaction|
				question = transaction.question.to_s
				p question
				
				transaction.passthrough!(UPSTREAM)
			end
		end
	end

	
end

p = HTTP_Over_DNSProxy.new
p.start



