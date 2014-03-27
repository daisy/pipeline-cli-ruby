require_rel './core/resource'

class QueueProcessor < ListResultProcessor
	def initialize
		super "//ns:job",QueueBuilder.new	
	end
end

class QueueResource< Resource
	def initialize
		super("/queue",{},QueueProcessor.new)
	end	
end

class QueueEntry
        attr_accessor :jobId, :score
        def initialize()
                @jobId=nil
                @score=0.0
        end
	def to_s
		return "#{@jobId}\t#{@score}"
	end

end

class QueueBuilder
	def fromXml(element)
		Ctxt.logger.debug("from element: #{element.to_s}")
		entry=QueueEntry.new()
		entry.jobId=element.attributes["id"]
                entry.score=element.attributes["computedPriority"]
		return entry 
	end

end
