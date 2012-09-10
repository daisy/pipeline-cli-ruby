class VersionCommand < Command
	def initialize()
		super("version")	
	end

	def execute(str_args)
		puts "Daisy Pipeline 2"
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
		return "dp2 version \n\tPrints version and exists" 
	end
end
