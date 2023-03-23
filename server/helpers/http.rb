require 'socket'

module Sender
        def send_http(data, host, port)
	        begin 
	        	sock =  TCPSocket.new(host,port)
	        rescue
	            r = query = <<-HTML
	              <html>                                           
	              <head><title>DNSRuby Bad Gateway</title></head>
	              <body bgcolor="white">                           
	              <center><h1>502 Bad Gateway</h1></center>  
	              <hr><center>DNSRuby</center>                       
	              </body>                                          
	              </html> 
	            HTML
	            return "HTTP/1.1 502 Bad Gateway\r\nServer:DNSRuby\r\nDate:#{Time.now}\r\nContent-Type: text/html Content-Length: #{r.size}\r\n\r\n#{r}\r\n"
	        end

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
