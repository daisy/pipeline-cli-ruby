require_rel "./core/resource"
require_rel "./core/result_processor"
class AliveResource < Resource
	def initialize
		super("/alive",{},AliveProcessor.new)
	end
	def getResource
		@result=Rest.get_resource(buildUri())
		return @resultProcessor.process(@result)
	end
end
class AliveProcessor < ResultProcessor
	def process(input)
		Ctxt.logger.debug("alive process input : #{input!=nil}")
		return nil if input==nil

		Ctxt.logger.debug("from element: #{input.to_s}")
		doc= Document.new input
		aliveElem=XPath.first(doc,"//ns:alive",Resource::NS)
		alive=Alive.new(aliveElem.attributes["mode"]=="local",aliveElem.attributes["authentication"],aliveElem.attributes["version"])

		return alive
	end
end

class Alive
	attr_accessor :local,:authentication,:version
	def initialize(local,authentication,version)
		@local=local
		@authentication=authentication
		@version=version
	end

end
