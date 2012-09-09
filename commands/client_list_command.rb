require_rel "./commands/command"
require_rel "./core/admin_link"

class ClientListCommand < Command

	def initialize
		super("list")
	end

	def execute(str_args)
		raise RuntimeError,help if str_args.size!=0
		begin
			clients=AdminLink.new.job_statuses
			clients.each { |client|
				str="[DP2] Id:#{client.id} (#{client.role})\n" 
				puts str
			}
			puts "[DP2] No clients found in the WS" if clients.size==0
			
		rescue Exception => e
			Ctxt.logger.debug(e)
			puts "\n[DP2] ERROR: #{e}\n\n"
		end
	end
	def help
		return "Retrieves the list of clients from the WS"	
	end
	def to_s
		return "#{@name}\t\t\t\t#{help}"	
	end
end
