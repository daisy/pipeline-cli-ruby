class VersionCommand < Command
	def initialize()
		super("version")	
	end

	def execute(str_args)
		puts "Pipeline 2 WS"
		puts "Version: #{Ctxt.conf[Conf::WS_VERSION]}"
		puts ""
		puts Ctxt.conf[Conf::PROG_NAME]  
		puts "Version: #{Ctxt.conf[Conf::VERSION]}"
		puts ""
	end
	def to_s
		return "#{@name}\t\t\t\tShows version and exits"	
	end
	def help
		return "#{Ctxt.conf[Conf::PROG_NAME]} version \n\tPrints version and exits" 
	end
end
