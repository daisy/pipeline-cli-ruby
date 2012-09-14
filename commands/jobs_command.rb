require_rel "./commands/command"

class JobsCommand < Command

	def initialize
		super("jobs")
	end

	def execute(str_args)
		raise RuntimeError,help if str_args.size!=0
		begin
			jobs=PipelineLink.new.job_statuses
			jobs.each { |job|
				str="Job Id:#{job.id}\n" 
				str+="\t Status: #{job.status}\n" 
				CliWriter::ln str
			}
			CliWriter::ln "No jobs were found on the WS" if jobs.size==0
			
		rescue Exception => e
			 
			Ctxt.logger.debug(e)
			CliWriter::err "#{e}\n\n"
			#puts to_s
		end
	end
	def help
		return "Shows the status for every job"	
	end
	def to_s
		return "#{@name}\t\t\t\t#{help}"	
	end
end
