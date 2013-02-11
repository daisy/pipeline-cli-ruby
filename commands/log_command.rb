require_rel "./commands/id_based_command"

class LogCommand < IdBasedCommand 

	def initialize
		super("log")
		@id=nil
		@output=nil
		build_parser
	end

	def execute(str_args)
			
		begin
			getId!(str_args)
			raise RuntimeError,"no output file provided" if @output==nil
			res=PipelineLink.new.job_log(@id,@output)#job_zip_result(@id,@output)
			CliWriter::ln "Log file for Job #{@id} stored at #{res}\n"
		rescue Exception => e
			 
			Ctxt.logger.debug(e)
			CliWriter::err "#{e}\n\n"
			puts help
		end
	end
	def help
		return @parser.help
	end
	def to_s
		return "#{@name}\t\t\t\tGets the job's log file"	
	end
	def build_parser

		@parser=OptionParser.new do |opts|
			opts.on("--file PATH","where to store the job's logfile") do |v|
				@output=v
			end
			addLastId(opts)
		end
		@parser.banner="#{Ctxt.conf[Conf::PROG_NAME]} "+ @name + " [options] JOBID"
	end
end
