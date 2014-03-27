require_rel "./commands/command"

class QueueCommand < Command
	def initialize
		super("queue")
	end

	def execute(str_args)
		raise RuntimeError,help if str_args.size!=0
                begin
                        entries=PipelineLink.new.queue
                        if entries.size ==0
                                CliWriter::ln "The queue is empty"  
                        else
                                count=1
                                entries.each { |entry|

                                        CliWriter::ln "#{count}. #{entry}"
                                        count+=1
                                }
                        end
			
		rescue Exception => e
			Ctxt.logger.debug(e)
			CliWriter::err "#{e}\n\n"
		end
	end

	def help
		return "Shows the job ids in the execution queue and their priorities"	
	end
	def to_s
		return "#{@name}\t\t\t\t#{help}"	
	end
end
