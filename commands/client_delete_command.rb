require_rel "./commands/id_based_command"

class ClientDeleteCommand < IdBasedCommand 

	def initialize
		super("delete")
		build_parser
	end

	def execute(str_args)
			
		begin
			getId!(str_args)	
			res=AdminLink.new.deleteClient(@id)
			str="The client wasn't deleted"
			if res 
				str="Client #{@id} has been deleted\n" 
				str+= "\n"
			end
			CliWritter::ln str
		rescue Exception => e
			 
			Ctxt.logger.debug(e)
			CliWritter::err " #{e}\n\n"
		end
	end
	def help
		return @parser.help
	end
	def to_s
		return "#{@name}\t\t\t\tDeletes a client"	
	end
	def build_parser
		@parser=OptionParser.new
		@parser.banner="#{Ctxt.conf[Conf::PROG_NAME]} "+ @name + " CLIENTID"
	end
end
