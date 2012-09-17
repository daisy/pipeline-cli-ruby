require_rel "./commands/id_based_command"

class ClientCommand < IdBasedCommand

	def initialize
		super("client")
		build_parser
	end
	def execute(str_args)
			
		begin
			getId!(str_args)	
			raise RuntimeError,"No CLIENTID was supplied" if @id==nil|| @id.empty?
			client=AdminLink.new.client(@id)
			CliWriter::ln client.to_s
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
		return "#{@name}\t\t\t\tShows the detailed info for a single client"	
	end
	def build_parser

		@parser=OptionParser.new 
		@parser.banner="#{Ctxt.conf[Conf::PROG_NAME]} "+ @name + " CLIENTID"
	end
end
