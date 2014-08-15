require_rel "./commands/id_based_command"

class DeleteCommand < IdBasedCommand 

	def initialize
		super("delete")
		build_parser
	end

	def execute(str_args)
			
		begin
			getId!(str_args)	
			raise RuntimeError,"JOBID is mandatory" if @id.empty?
			res=PipelineLink.new.delete_job(@id)
			str="The job wasn't deleted"
			if res 
				str="Job #{@id} has been deleted\n" 
				str+= "\n"
			end
			CliWriter::ln str
		rescue Exception => e
			 
			Ctxt.logger.debug(e)
			CliWriter::err "#{e}\n\n"
			puts help 
                        return -1 
		end
                return 0
	end
	def help
		return @parser.help
	end
	def to_s
		return "#{@name}\t\t\t\tDeletes a job"	
	end
	def build_parser

		@parser=OptionParser.new do |opts|
			addLastId(opts)
		end
		@parser.banner="#{Ctxt.conf[Conf::PROG_NAME]} "+ @name + " JOBID"
	end
end
