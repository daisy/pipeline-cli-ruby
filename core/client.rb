require_rel './core/ctxt'
require_rel './core/resource'
require_rel "./core/result_processor"

class ClientListResource < Resource
	def initialize
		super("/admin/clients",{},ClientsResultProcessor.new)
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
