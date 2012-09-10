require_rel './core/ctxt'
require_rel './core/resource'
require_rel "./core/result_processor"

class ClientListResource < Resource
	def initialize(*id)
		if id.empty? 
			super("/admin/clients",{},ClientsResultProcessor.new)
		else
			super("/admin/clients",{:id=>id},ClientsResultProcessor.new)

		end
	end	
	def buildUri
		
		if @params[:id]!=nil
			uri = "#{Ctxt.conf[Ctxt.conf.class::BASE_URI]}#{@path}/#{@params[:id]}"
			Ctxt.logger.debug("URI:"+uri)
		else
			uri=super
		end
		uri
	end
end

class ClientsResultProcessor < ListResultProcessor
	def initialize
		super("//ns:client",ClientBuilder.new)
	end

	def badRequest(err,resource)
		Ctxt.logger.debug("WS 400: "+resource.buildUri)
		raise RuntimeError,err.desc
	end
end
class DeleteClientResource < Resource
	def initialize(id)
		super("/admin/clients",{:id=>id},DeleteClientResultProcessor.new)
	end	
	def buildUri
    		uri = "#{Ctxt.conf[Ctxt.conf.class::BASE_URI]}#{@path}/#{@params[:id]}"
		Ctxt.logger.debug("URI:"+uri)
		uri
	end
end
class DeleteClientResultProcessor < ResultProcessor
	def process(bool)
		return bool
	end
	def notFound(err,resource)
		raise RuntimeError,"Client #{resource.params[:id]} not found"
	end
end


class Client
	ROLES=["ADMIN","CLIENTAPP"]
	attr_accessor :id,:secret,:role,:contact,:href
	def initialize
		@id=""
		@secret=""
		@role=""
		@contact=""
		@href=""
		
	end

	def to_s
		s="Client id: #{@id}\n"
		s+="\tSecret: #{@secret}\n"
		s+="\tRole: #{@role}\n"
		s+="\tContact: #{@contact}\n"
	end
end
class ClientBuilder
	NS=Resource::NS["ns"]
	E_CLIENT='client'
	A_HREF='href'
	A_ID='id'
	A_SECRET='secret'
	A_ROLE='role'
	A_CONTACT='contact'
	def fromXml(element)
		Ctxt.logger.debug("client from xml: #{element.to_s}")
		client= Client.new
		client.id=element.attributes[A_ID]
		client.secret=element.attributes[A_SECRET]
		client.role=element.attributes[A_ROLE]
		client.contact=element.attributes[A_CONTACT]
		client.href=element.attributes[A_HREF]
		return client
	end
	def toXml(client)
		doc= Document.new
		clientElem=Element.new E_CLIENT
		clientElem.add_namespace(NS)
		clientElem.attributes[ A_HREF ] =client.href
		clientElem.attributes[ A_ID ]=client.id
		clientElem.attributes[ A_SECRET ]=client.secret
		clientElem.attributes[ A_ROLE ]=client.role.upcase
		clientElem.attributes[ A_CONTACT ]=client.contact
		doc<< clientElem
		return doc
	end
	
end
