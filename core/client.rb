require_rel './core/ctxt'
require_rel './core/resource'
require_rel "./core/result_processor"

class ClientListResource < Resource
	def initialize(*id)
		if id.empty? 
			super("/admin/clients",{},ClientsResultProcessor.new)
		else
			super("/admin/clients",{:id=>id[0]},ClientResultProcessor.new)

		end
	end	
end

class ClientsResultProcessor < ListResultProcessor
	def initialize
		super("//ns:client",ClientBuilder.new)
	end

end
class ClientResultProcessor < ClientsResultProcessor
	def process (input)
		list= super	
		return list[0]
	end
end
class DeleteClientResource < Resource
	def initialize(id)
		super("/admin/clients",{:id=>id},DeleteResultProcessor.new("Client"))
	end	
end


class Client
	ROLES=["ADMIN","CLIENTAPP"]
	attr_accessor :id,:secret,:role,:contact,:href,:priority
	def initialize
		@id=""
		@secret=""
		@role=""
		@contact=""
		@href=""
		@priority=""
		
	end

	def to_s
		s="Client id: #{@id}\n"
		s+="\tSecret: #{@secret}\n"
		s+="\tRole: #{@role}\n"
		s+="\tContact: #{@contact}\n"
		s+="\tPriority: #{@priority}\n"
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
	A_PRIORITY='priority'
	def fromXml(element)
		Ctxt.logger.debug("client from xml: #{element.to_s}")
		client= Client.new
		client.id=element.attributes[A_ID]
		client.secret=element.attributes[A_SECRET]
		client.role=element.attributes[A_ROLE]
		client.contact=element.attributes[A_CONTACT]
		client.href=element.attributes[A_HREF]
		client.priority=element.attributes[A_PRIORITY]
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
		clientElem.attributes[ A_PRIORITY]=client.priority
		doc<< clientElem
		return doc
	end
	
end
