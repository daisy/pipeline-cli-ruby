require_rel "./commands/id_based_command"

class ResultCommand < IdBasedCommand 

	def initialize
		super("result")
		@id=nil
		@output=nil
		@type=nil
		@oname=nil
		@idx=nil
		build_parser
	end

	def execute(str_args)
			
		begin
			getId!(str_args)
			raise RuntimeError,"no output file provided" if @output==nil
			if( @idx !=nil and (@oname==nil or @type==nil))
				raise RuntimeError,"Result idx selected but no output oname or output type" 
			elsif ( @oname!=nil and @type==nil)
				raise RuntimeError,"Result name selected but no output type provided" 
			end
			res=PipelineLink.new.job_zip_result(@id,@output,@type,@oname,@idx)
			CliWriter::ln "Job #{@id} stored at #{res}\n"
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
		return "#{@name}\t\t\t\tGets the zip file containing the job results"	
	end
	def build_parser

		@parser=OptionParser.new do |opts|
			opts.on("--file PATH","where to store the job's result") do |v|
				@output=v
			end

			opts.on("--type [OUTPUT_TYPE]","Type of the desired output (port or option)") do |v|
				@type=v
			end

			opts.on("--name [NAME]","Name of the output to retrieve") do |v|
				@oname=v
			end

			opts.on("--index [IDX]","index of the output to retrieve") do |v|
				@idx=v
			end
			addLastId(opts)
		end
		@parser.banner="#{Ctxt.conf[Conf::PROG_NAME]} "+ @name + " [options] JOBID"
	end
end
