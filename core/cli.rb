require_rel './commands/conf_parser'
class Cli
	def initialize(dirName,progName,shortProgName,version)
		@dyn_cmds={}	
		@static_cmds={}
		initConf(dirName,progName,shortProgName,version)	
		@cnfParser= ConfParser.new
	end

	def initConf(dirName,progName,shortProgName,version)
		if ENV["OCRA_EXECUTABLE"]==nil
			Ctxt.conf(File.expand_path("config.yml",dirName))
		else
			Ctxt.conf(File.expand_path("config.yml",dirName))
		end
		Ctxt.conf[Conf::PROG_NAME]=progName
		Ctxt.conf[Conf::SHORT_NAME]=shortProgName
		Ctxt.conf[Conf::BASE_DIR]=dirName
		Ctxt.conf[Conf::VERSION]=version
	end

	def addDynamicCommand(command)
		load(command,@dyn_cmds)
	end
	def addStaticCommand(command)
		load(command,@static_cmds)
	end
	
	def main(args)
                ret=0
		cmd,args=checkArgs(args)
		if cmd==nil
			puts "Usage: #{Ctxt.conf[Conf::PROG_NAME]} command [options]\n"
			puts "type #{Ctxt.conf[Conf::PROG_NAME]} help for more info\n"
			return -1 
		end
		ver=VersionCommand.new
		@static_cmds["help"]=HelpCommand.new(@static_cmds,@dyn_cmds,ver,@cnfParser)
		@static_cmds[ver.name]=ver
		error=""
		hasErr=false
		cmds=@static_cmds.merge(@dyn_cmds)
		if cmds.has_key?(cmd)
			begin
				Ctxt.logger.debug("cmd #{cmd}")
				ret=cmds[cmd].execute(args[1..-1])
                                if ret==nil
                                        ret=0
                                end 
			rescue Exception=>e
				error=e.message
				hasErr=true	
			end
		else
			hasErr=true
		end

		if hasErr
			CliWriter::err( "#{error}\n\n") if error!=nil && !error.empty?
			puts cmds["help"].help
			return ret=-1 
		end
		return ret 
	end
	
	def checkArgs(args)
		if args.empty?
			return nil	
		end
		#parse config
		args=@cnfParser.parse(args)
		#get command
		cmd=nil
		args.each do |a|
			cmd = a
			break
		end
		return cmd,args
	end
	def load(cmd,cmds)
		cmds[cmd.name]=cmd
		return cmds
	end

end

class CliWriter
	def self.ln(str)
		puts "[#{Ctxt.conf[Conf::SHORT_NAME]}] #{str}"		
	end
	def self.ws(str)
		puts "[WS] #{str}"		
	end
	def self.err(str)
		puts "[ERROR] #{str}"		
	end
end
