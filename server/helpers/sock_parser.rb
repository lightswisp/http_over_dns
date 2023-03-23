class SockParser
    def initialize(buffer)
        @buffer = buffer
    end

    def parse()
    	begin
	        request = @buffer.split("\r\n")
			start_line = request[0].split(" ")
			return {
				"method" => start_line[0], 		# GET, POST, PUT, DELETE, CONNECT, ETC...
				"path" => start_line[1],   		# /
				"version" => start_line[2],		# HTTP/1.1 
				"headers" => request[1..-1],    # Content-type: blah-blah; User-Agent: blah-blah
	            "host" => request[1..-1].select {|l| l=~/Host/}[0].gsub("Host:", "")[1..-1].split(":")[0],
	            "port" => (request[1..-1].select {|l| l=~/Host/}[0].gsub("Host:", "")[1..-1].split(":")[1]) || "80"
			}
		rescue
			return nil
		end
    end

    def valid?()
        return true if self.parse() 	
		return false
    end
end
