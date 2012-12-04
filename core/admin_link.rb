class AdminLink
	def initialize
		#init the link to the pipeline
		@plink=PipelineLink.new	
	end
	def client(id)
		return ClientListResource.new(id).getResource
	end

	def clientList
		return ClientListResource.new.getResource
	end
	def createClient(client)
		return ClientListResource.new.postResource(ClientBuilder.new.toXml(client).to_s,nil)
	end
	def modifyClient(client)
		return ClientListResource.new(client.id).putResource(ClientBuilder.new.toXml(client).to_s)
	end
	def deleteClient(id)
		return DeleteClientResource.new(id).deleteResource
	end

	def properties()
		return PropertiesResource.new.getResource
	end

end
