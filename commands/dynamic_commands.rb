require_rel "./core/pipeline_link"
require_rel "./core/helpers"
class DynamicCommands

	def self.get
		commands=[]
		scripts=PipelineLink.new.scripts
		scripts.values.each { |script| commands.push(CommandScript.new(script))}
		return commands
	end

end

class CommandScript < Command
	attr_accessor :script,:opt_modifiers,:input_modifiers,:output_modifiers
	def initialize(script)
		super(script.id)
		@script=script.clone
		@opt_modifiers={}
		@input_modifiers={}
		@output_modifiers={}
		@background=false
		@persistent=false
		@data=nil
		@outfile=nil
		@quiet=false
		@source=nil
		@niceName=nil
		
		build_modifiers
		build_parser
	end
	def execute(str_args)
		begin
			dp2ws=PipelineLink.new
			@parser.parse(str_args)	
			raise RuntimeError,"dp2 is running in remote mode, so you need to supply a zip file containing the data (--data)" if Ctxt.conf[Ctxt.conf.class::LOCAL]!=true && @data==nil
			raise RuntimeError,"dp2 is running in remote mode, so you need to supply an output file to store the results (--file)" if Ctxt.conf[Ctxt.conf.class::LOCAL]!=true && @outfile==nil && !@background

			CliWriter::ln "IGNORING #{@outfile} as the job is set to be executed in the background"  if @outfile!=nil && @background

			if @outfile!=nil && !@background
				raise RuntimeError,"#{@outfile}: directory doesn't exists " if !File.exists?(File.dirname(File.expand_path(@outfile)))
			end	
			job=dp2ws.job(@script,@niceName,@data,!@background,@quiet)
			#store the id of the current job
			Helpers.last_id_store(job)
			if Ctxt.conf[Ctxt.conf.class::LOCAL]!=true && !@background &&job.status=="DONE"
				dp2ws.job_zip_result(job.id,@outfile)
				CliWriter::ln "Result stored at #{@outfile}"
			end
				
			if !@persistent && job.status=="DONE"
				if  dp2ws.delete_job(job.id)
					CliWriter::ln " The job #{job.id} has been deleted from the server"
				end

			end
			if !@background
				CliWriter::ln "#{job.status}"
			end
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
		s="#{@script.id}\t\t\t#{@script.desc}"
		return s
	end

	def build_parser


		@parser=OptionParser.new do |opts|
			
			@input_modifiers.keys.each{|input|
				@input_modifiers[input][:value]=nil
				if @input_modifiers[input][:sequenceAllowed]=='true'
					opts.on(input+" input1,input2,input3",Array,@input_modifiers[input][:help]) do |v|
					   @input_modifiers[input][:value] = v
					end
				else
					opts.on(input+" input",@input_modifiers[input][:help]) do |v|
					   @input_modifiers[input][:value] = [v]
					end
				end

			}
			@output_modifiers.keys.each{|output|
				@output_modifiers[output][:value]=nil
				if @output_modifiers[output][:sequenceAllowed]=='true'
					opts.on(output+" output1,output2,output3",Array,@output_modifiers[output][:help]) do |v|
					   @output_modifiers[output][:value] = v
					end
				else
					opts.on(output+" output",@output_modifiers[output][:help]) do |v|
					   @output_modifiers[output][:value] = [v]
					end
				end

			}

			@opt_modifiers.keys.each{|option|
				@opt_modifiers[option][:value]=nil
				opts.on(option+ @opt_modifiers[option][:tail],@opt_modifiers[option][:help]) do |v|
				    @opt_modifiers[option][:value] = v
				end
			}
			if Ctxt.conf[Ctxt.conf.class::LOCAL]!=true
				opts.on("--file FILE","-f FILE","Zip file where to store the results from the server(not applied if running in background mode)") do |v|
					@outfile=v
				end
				opts.on("--data ZIP_FILE","-d ZIP_FILE","Zip file with the data needed to perform the job (Keep in mind that options and inputs MUST be relative uris to the zip file's root)") do |v|
					@data=File.open(File.expand_path(v), "rb")
				end
			end
			opts.on("-n","--name [NAME]","Job's nice name" )do |v|
				@niceName=v
			end
			opts.on("--background","-b","Runs the job in the background (will be persistent)") do |v|
				@background=true
				@persistent=true
			end
			opts.on("--persistent","-p","Forces to keep the job data in the server") do |v|
				@persistent=true
			end
			opts.on("--quiet","-q","Doesn't show the job messages") do |v|
				@quiet=true
			end
		end
		
		@parser.program_name="#{Ctxt.conf[Conf::PROG_NAME]} "+ @name
	end

	def build_modifiers
		@script.opts=@script.opts.sort_by{ | v | v[:required] }.reverse	
		@script.opts.each {|opt|
			modifier="--x-#{opt[:name]} "
			if opt[:required]=="true"
				opt[:tail]= " #{opt[:type]}"
			else
				opt[:tail]= " [#{opt[:type]}]"
			end
			opt[:help]= ""
			opt[:help]+= " (required)" if opt[:required]=="true" 
			opt[:help]+= " #{opt[:desc]}\n"
			opt[:help]+= " (#{opt[:mediaType]})" if opt[:mediaType]!=nil and !opt[:mediaType].empty?
			@opt_modifiers[modifier]=opt
			
			
		}
		@script.inputs.each {|input|
			modifier="--i-#{input[:name]}"
			input[:help] ="#{input[:desc]}"
			input[:help] +=" (#{input[:mediaType]})" if input[:mediaType]!=nil and !input[:mediaType].empty?
			@input_modifiers[modifier]=input
			#@source==input if input[:name]=="source"
		}
		@script.outputs.each {|out|
			modifier="--i-#{out[:name]}"
			out[:help] ="#{out[:desc]}"
			out[:help] +=" (#{out[:mediaType]})" if out[:mediaType]!=nil and !out[:mediaType].empty?
			@output_modifiers[modifier]=out
		}
	end
end
