require 'socket'
require_relative 'sock_parser'


class Proxy
	def initialize(port, handler)
		@port = port
		@handler = handler
		@server = TCPServer.new(port)
	end

	def start()

		loop do
			Thread.new(@server.accept) do |client|
				raw_request     = client.recvmsg().first
				parser = SockParser.new(raw_request)
				parsed_request  = parser.parse()
				@handler.call([raw_request, parsed_request], client) if parser.valid?# call the event handler
			end
		end

	end

	
end


