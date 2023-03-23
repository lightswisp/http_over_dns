
class DNSParser
	
	def initialize()
		@packets   = {}
		@readable_unique_ids = []
	end

	def parse(parts)
		last, id, unique_id, size, payload = parts[0], parts[1], parts[2], parts[3], parts[4]
		@packets[unique_id] = [] if !@packets[unique_id]
		@packets[unique_id][id.to_i] = payload

		@readable_unique_ids.append(unique_id) if last == "1" && @packets[unique_id].join.size == size.to_i && !@packets[unique_id].include?(nil)
		return unique_id
	end

	def get_packets(unique_id)
		return @packets[unique_id]
	end

	def is_readable?(unique_id)
		return @readable_unique_ids.include?(unique_id)
	end

	def cleanup(unique_id)
		@readable_unique_ids.delete(unique_id) if @readable_unique_ids.include?(unique_id)
		@packets.delete(unique_id)
	end
end
