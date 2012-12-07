require_rel "./commands/command"

class IdBasedCommand < Command
	def initialize(name)
		super(name)	
		@lastid=false
	end

	def getId!(str_args) 
		@id=@parser.parse(str_args)
		#ruby 1.9 issues with strings and arrays, they may not be issues 
		#but they behave differently from version 1.8.
		@id = @id[0] if @id.size > 0
		if @lastid 
			@id=Helpers.last_id_read()
		end
		
		#if @id==nil
			#raise RuntimeError "No job id"
		#end

	end

	def addLastId(opts)
		opts.on("-l","--lastid","Uses the id of the last job executed") do |v|
			@lastid=true
		end
	end

end
