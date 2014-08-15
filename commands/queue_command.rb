require_rel "./commands/command"

class QueueCommand < Command
	def initialize
		super("queue")
                @id=nil
                @up=false
                @down=false
                build_parser
                
	end

	def execute(str_args)
		raise RuntimeError,help if str_args.size!=0 && str_args.size!=2
                begin
                        @parser.parse(str_args)
                        entries=[]

                        if @id!=nil
                                if @up && @down
                                        raise "Up and down are mutually exclusive"
                                end
                                if @up
                                        entries=PipelineLink.new.queue_up(@id)
                                else
                                        entries=PipelineLink.new.queue_down(@id)
                                end

                        else
                                entries=PipelineLink.new.queue
                        end
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
                        return -1
		end
                return 0
	end

	def help
		return @parser.help
	end
	def to_s
		return "#{@name}\t\t\t\tShows and manipulates the execution queue"	
	end
	def build_parser
                @parser=OptionParser.new do |opts|
                        opts.on("-u JOBID","--up JOBID","(Optional) moves the job up the execution queue") do |v|
                                @up=true
                                @id =v
                        end

                        opts.on("-d [JOBID]","--down [JOBID]","(Optional) moves the job down the execution queue") do |v|
                                @down=true
                                @id=v
                        end
                end
                @parser.banner="#{Ctxt.conf[Conf::PROG_NAME]} "+ @name + " [options] Shows and manipulates the execution queue "
	end
end
