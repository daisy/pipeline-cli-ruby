require_rel "core/client"
class ClientCreateCommand < Command

	def initialize
		super("create")
		@client=Client.new
		build_parser
	end
	def execute(str_args)

			
		begin
			@parser.parse(str_args)
			Ctxt.logger.debug("client #{@client.to_s}")
			if @client.id.empty? || @client.secret.empty? || @client.role.empty?
				raise RuntimeError," Client id, secret and role are mandatory"
			end
			client=AdminLink.new.createClient(@client)
			CliWriter::ln "Client succesffully created\n#{client}\n"	
		rescue Exception => e
			 
			Ctxt.logger.debug(e)
			CliWriter::err "#{e.message}\n\n"
			puts help
		end
	end
	def help
		return @parser.help
	end
	def to_s
		return "#{@name}\t\t\t\tCreates a new client"	
	end
	def build_parser
		roles=(Client::ROLES + Client::ROLES.map{|i| i.downcase})
		@parser=OptionParser.new do |opts|
			opts.on("-i CREATE","--id CLIENTID","Client id") do |v|
				@client.id =v
			end
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
		@parser.banner="dp2admin "+ @name + " [options] "
	end
end
