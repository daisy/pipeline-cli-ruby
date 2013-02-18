require_rel "./commands/id_based_command"

class JobCommand < IdBasedCommand

	def initialize
		super("status")
		@showMsgs=false
		build_parser
	end
	def execute(str_args)
			
		begin
			getId!(str_args)	
			raise RuntimeError,"JOBID is mandatory" if @id.empty?
			job=PipelineLink.new.job_status(@id,0)
			str="No such job"
			if job != nil 
				str="Job Id:#{job.id}\n" 
				str+="\t Status: #{job.status}\n" 
				str+="\t Script: #{job.script.id}\n"
				if @showMsgs 
					job.messages.each{|msg| str+=msg.to_s+"\n"}
				end
				str+= "\n"
			end
			CliWriter::ln str
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
		return "#{@name}\t\t\t\tShows the detailed status for a single job"	
	end
	def build_parser

		@parser=OptionParser.new do |opts|
			opts.on("-v","Shows the job's log messages") do |v|
				@showMsgs=true
			end
			addLastId(opts)
		end
		@parser.banner="#{Ctxt.conf[Conf::PROG_NAME]} "+ @name + " [options] JOBID"
	end
end
