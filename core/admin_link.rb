class AdminLink
	def initialize
		#init the link to the pipeline
		@plink=PipelineLink.new	
	end

	def clientList
		return ClientListResource.new.getResource
	end
	def createClient(client)
		return ClientListResource.new.postResource(ClientBuilder.new.toXml(client).to_s,nil)
	end
	def deleteClient(id)
		return DeleteClientResource.new(id).deleteResource
	end


end
