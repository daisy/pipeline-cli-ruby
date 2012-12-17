class ConfParser
	def initialize
		build_parser
	end

	def help
		return @parser.help
	end

	def parse(args)
		unknown=[]
		nonopts=[]
		#This parses only the subset of args related to the global configuration items
		args=cleanSwitches(args)
		begin
			@parser.order!(args) do |nop|
				Ctxt.logger.debug("no option yieled #{nop}")
				nonopts << nop
			end
		rescue OptionParser::InvalidOption=> e
			e.recover args	
			unknown << args.shift
			unknown << args.shift if args!=nil and args.size>0 and args.first[0..0]!='-'
			retry
		end
		nonopts.reverse.each { |nonopt| unknown.unshift(nonopt)}
		unknown=revertSwitches(unknown)
		return unknown
	end	
	#Cleans the args of -x they are not valid for conf 
	#but may be used by other subcommands
	#hackish dirty way to workaround ths
	#TODO: reimplement the hole command parsing 
	#part, optparser is not the best way
	def cleanSwitches(args)
		clean=[]
		args.each do |arg|
			clean << arg.sub(/^-(\w)/,'+\1')
		end
		return clean
	end
	def revertSwitches(args)
		clean=[]
		args.each do |arg|
			clean << arg.sub(/^\+(\w)/,'-\1')
		end
		return clean
	end
	def build_parser
		@parser=OptionParser.new do |opts|
			Conf::CONFIG_ITEMS.sort.each do |name,desc|
				if Conf::CONST_FILTER.index(name)==nil 	
					opts.on("--#{name} VALUE",desc+" default: ("+Ctxt.conf[name].to_s+")") do |v|
						Ctxt.logger.debug("Configuring#{name} with value #{v}") 
						Ctxt.conf[name]=v	
						Ctxt.conf.update_vals
					end
				end
			end
		end
		#optparser issue: linux ruby seems to ignore @parser.version=nil to ignore the --version flag
		@parser.version=": Use #{@parser.program_name} version to get full the version description"
		

		@parser.banner="Global CLI switches:"
	end
end
