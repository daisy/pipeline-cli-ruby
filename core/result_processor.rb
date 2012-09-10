class ResultProcessor


	def process(input)
		raise NotImplementedError 	
	end

	def notFound(err,resource)
		Ctxt.logger.debug("WS 404: "+resource.buildUri)
		raise RuntimeError, "Resource not found"

	end
	def badRequest(err,resource)
		Ctxt.logger.debug("WS 400: "+resource.buildUri)
		raise RuntimeError, "Bad Request"

	end
	def error(err,resource)
		Ctxt.logger.debug("Generic error: "+resource.buildUri)
		raise RuntimeError, "WS Failure"
	end
	def internalError(err,resource)
		Ctxt.logger.debug("WS 500 :"+resource.buildUri)
		Ctxt.logger.debug("WS 500 :"+err.desc) if err.desc != nil
		Ctxt.logger.debug("WS 500 :"+err.trace) if err.trace != nil
		raise RuntimeError, "WS Internal Failure:\n\n#{err.desc}"
	end
end


class ListResultProcessor < ResultProcessor
	def initialize (xpath,builder) 
		@xpath=xpath
		@builder=builder
	end

	def process(input)
		raise RuntimeError,"Empty response from the server" if input==nil || input.empty?
		doc= Document.new input
		objs=[]
		XPath.each(doc,@xpath,Resource::NS) { |xobj|
			objs<<@builder.fromXml(xobj)
		}
		Ctxt.logger.debug("Objs retrieved #{objs.size}")
		return objs 
	end
end
