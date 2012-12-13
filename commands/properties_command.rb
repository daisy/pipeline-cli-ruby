require_rel "./commands/id_based_command"

class PropertiesCommand  < Command

	def initialize
		super("properties")
		build_parser
	end
	def execute(str_args)
			
		begin
			properties=AdminLink.new.properties
			properties.each{ |prop|
				CliWriter::ln prop.to_s
			}
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
		return "#{@name}\t\t\t\tShows a list of properties detailing the WS configuration"	
	end
	def build_parser

		@parser=OptionParser.new 
		@parser.banner="#{Ctxt.conf[Conf::PROG_NAME]} "+ @name 
	end
end
