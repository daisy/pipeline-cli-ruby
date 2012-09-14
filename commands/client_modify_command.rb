require_rel "core/client"
class ClientModifyCommand < IdBasedCommand

	def initialize
		super("modify")
		@client=Client.new
		build_parser
	end
	def execute(str_args)

			
		begin
			link=AdminLink.new
			getId!(str_args)	
			raise RuntimeError,"No CLIENTID was supplied" if @id==nil|| @id.empty?
			@parser.parse(str_args)
			@client.id=@id;

			Ctxt.logger.debug("client #{@client.to_s}")
			orig=link.client(@id)
			fill(orig)
			client=link.modifyClient(@client)
			CliWriter::ln "Client succesfully modified\n#{client}\n"	

		rescue Exception => e
			Ctxt.logger.debug(e)
			CliWriter::err "#{e.message}\n\n"
			puts help
		end
	end
	
	def fill (other)
		if @client.role.empty?
			@client.role=other.role
		end
		if @client.secret.empty?
			@client.secret=other.secret
		end
		if @client.contact.empty?
			@client.contact=other.contact
		end
		
	end

	def help
		return @parser.help
	end
	def to_s
		return "#{@name}\t\t\t\tModifys the client info"	
	end
	def build_parser
		roles=(Client::ROLES + Client::ROLES.map{|i| i.downcase})
		@parser=OptionParser.new do |opts|
			opts.on("-r ROLE","--role ROLE ",Client::ROLES,roles,"Client role  (#{Client::ROLES.join(',')})") do |v|
				@client.role=v.upcase
			end
			opts.on("-c CONTACT","--contact CONTACT","Client contact e-mail") do |v|
				@client.contact=v
			end
			opts.on("-s SECRET","--secret SECRET","Client secret") do |v|
				@client.secret=v
			end
		end
		@parser.banner="#{Ctxt.conf[Conf::PROG_NAME]} "+ @name + " [options] CLIENTID"
	end
end
