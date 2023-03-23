class DNSParser

	def initialize()
		@packets   = []
		@is_readable = false
	end

	def parse(part)

		part = part.to_s.scan(/@strings=\["(.*?)"\]/).map{|a| a[0]}.join

		return if part.include?("NULL")
		if part.include?("END")
			@is_readable = true
			part = part.gsub("END", "")
		end
		@packets << part
		
	end

	def get_packets()
		return @packets
	end

	def is_readable?
		return @is_readable
	end

	def cleanup()
		@packets   = []
		@is_readable = false
	end	

end
