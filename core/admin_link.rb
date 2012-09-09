class AdminLink
	def initialize
		#init the link to the pipeline
		@plink=PipelineLink.new	
	end

	def clientList
		return ClientListResource.new.getResource
	end


end
