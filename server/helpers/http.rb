require 'socket'


## TODO
# FIX THE INCOMPLETE RESPONSE READING

module Sender
	def send_http(data, host, port)	
		sock =  TCPSocket.new(host,port)
		return nil if !sock
		buff = ""
		sock.print(data)

		while IO.select([sock], nil, nil, 0.1) && (line = sock.recv(1024 * 16))
        	buff << line
   		end
		
		return buff
		
	end

	def get_chunks(data, size) # chunks helper function
		data.unpack("a#{size}" * (data.size/size.to_f).ceil)
	end
end
