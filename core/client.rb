require_rel './core/ctxt'
require_rel './core/resource'

class ClientListResource
	def initialize
		super("/admin/clients",ClientsResultProcessor.new)
	end
end

class ClientsResultProcessor < ResultProcessor
	def initialize
		super("//ns:client",ClientBuilder.new)
	end
end


class Client
	attr_accessor :id,:secret,:role,:contact,:href
	def initialize
	end

	def to_s
		s="Client id: #{@id}\n"
		s+="\tSecret: #{@secret}\n"
		s+="\tRole: #{@role}\n"
		s+="\tContact: #{@contact}\n"
	end
end
class ClientBuilder
	def fromXml(element)
		Ctxt.logger.debug("client from xml: #{element.to_s}")
		client= Client.new
		client.id=element.attributes["id"]
		client.secret=element.attributes["secret"]
		client.role=element.attributes["role"]
		client.contact=element.attributes["contact"]
		client.href=element.attributes["href"]
		return client;
	end
	
end
