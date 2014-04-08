require_rel './core/resource'
class JobResource < Resource
	def initialize
		super("/jobs",{},JobStatusResultProcessor.new)
	end	
end
class JobStatusResource < Resource
	def initialize(id=nil,seq=nil)
		args={}
		args[:id]=id if id!=nil
		args[:seq]=seq if seq!=nil
		if id == nil
			super("/jobs",args,JobsStatusResultProcessor.new)
		else
			super("/jobs",args,JobStatusResultProcessor.new)
		end
	end	
	def buildUri
		uri=super
		if @params[:seq] != nil
			uri = "#{uri}?msgSeq=#{@params[:seq]}"
		end
		Ctxt.logger.debug("URI:"+uri)
		uri
	end
end
class DeleteJobResource < Resource
	def initialize(id)
		super("/jobs",{:id=>id},DeleteResultProcessor.new("Job"))
	end	
end
class JobResultZipResource < Resource
	def initialize(id,output_path,type,name,idx)
		super("/jobs",{:id=>id,:type=>type,:name=>name,:idx=>idx},StoreToFileProcessor.new(output_path))
	end	
	def buildUri
    		uri = "#{super}/result"
		uri+="/#{@params[:type]}" if @params[:type]!=nil
		uri+="/#{@params[:name]}" if @params[:name]!=nil
		uri+="/idx/#{@params[:idx]}" if @params[:idx]!=nil
		Ctxt.logger.debug("URI:"+uri)
		uri
	end
end


class JobLogResource < Resource
	def initialize(id,output_path)
		super("/jobs",{:id=>id},StoreToFileProcessor.new(output_path))
	end	
	def buildUri
    		uri = "#{super}/log"
		Ctxt.logger.debug("URI:"+uri)
		uri
	end
end


class StoreToFileProcessor < ResultProcessor
	def initialize(path)
		@path=path	
	end
	def process(input)
		f=File.open(@path, 'wb')
		f.write(input)
		f.close
		return @path
	end
	def notFound(err,resource)
		raise RuntimeError,"Job #{resource.params[:id]} not found"
	end
end




class JobsStatusResultProcessor < ListResultProcessor
	def initialize
		super "//ns:job",JobBuilder.new	
	end
end
class JobStatusResultProcessor < JobsStatusResultProcessor
	#list of one element
	def process (input)
		list= super	
		return list[0]
	end
end
class Message
	attr_accessor :msg,:level,:seq
	def to_s
			return "#{@level}(#{@seq}) - #{@msg}"
	end
end
class Job

	attr_accessor :id,:status,:script,:messages,:log,:nicename,:results,:priority
	def initialize(id)	
		@id=id
		@messages=[]
		@results=nil;
	end

	def to_s
		s="Job Id: #{@id}\n"
		s+="\t Status: #{@status}\n"
		s+="\t Name: #{@nicename}\n"
		s+="\t Priority: #{@priority}\n"
		s+="\t Script: #{@script.uri}\n" if @script!=nil
		s+="\t Result: #{@results.href}\n" if @result!=nil
		s+="\t Log: #{@log}\n" if @log!=nil
		s+="\t Messages: #{@messages.size}\n"
		s+="\n"
		return s	
	end	

end
class  Results

#<results href="http://localhost:8182/ws/jobs/fe930094-2969-4609-92d2-9af2f6e29ad4/result" mime-type="zip">
  #<result from="option" href="http://localhost:8182/ws/jobs/fe930094-2969-4609-92d2-9af2f6e29ad4/result/option/output-dir" mime-type="zip" name="output-dir">
    #<result href="http://localhost:8182/ws/jobs/fe930094-2969-4609-92d2-9af2f6e29ad4/result/option/output-dir/epub/EPUB/valentin.jpg" mime-type=""/>
    #<result href="http://localhost:8182/ws/jobs/fe930094-2969-4609-92d2-9af2f6e29ad4/result/option/output-dir/epub/EPUB/hauy_valid-1.xhtml" mime-type=""/>
  #</result>
#</results>
	attr_accessor :ports,:options,:href
	def initialize()
		@ports=[]
		@options=[]
		@href
	end
	def to_s
		st=""
		@ports.each{|port|
			st+="Port name: #{port[:name]}\n"
			port[:children][:idx].each(){|child|
				st+="\t + result idx: #{child}\n"
			}
		}
		st+="\n"
		@options.each{|opt|
			st+="Option name: #{opt[:name]}\n"
			opt[:children][:idx].each(){|child|
				st+="\t + result idx: #{child}\n"
			}
		}
		return st
	end
	def self.fromXml(element)
		res=Results.new
		res.href=element.attributes["href"]
		XPath.each(element,"./ns:result",Resource::NS){|resElm|
			from=resElm.attributes["from"]
			name=resElm.attributes["name"]
			href=resElm.attributes["href"]
			idxs=[]
			mimes=[]
			resElm.each_element(){ |child|
				idxs<<child.attributes["href"].sub(res.href,'').sub("/#{from}/#{name}/idx/",'')
				mimes<<child.attributes["mime"]
			}

			resElm={:type=>from,:name => name, :href => href, :children=> {:idx=>idxs,:mimes=>mimes}}
			if from=="port"
				res.ports<<resElm;
			else
				res.options<<resElm;
			end


		}
		return res
	end
end
class JobBuilder
	def fromXml(element)
		Ctxt.logger.debug("from element: #{element.to_s}")
		job=Job.new(element.attributes["id"])
		job.status=element.attributes["status"]
                job.priority=element.attributes["priority"]
	
		xscript=XPath.first(element,"./ns:script",Resource::NS)
		xnicename=XPath.first(element,"./ns:nicename",Resource::NS)
		xresult=XPath.first(element,"./ns:results",Resource::NS)
		xlog=XPath.first(element,"./ns:log",Resource::NS)
		XPath.each(element,"./ns:messages/ns:message",Resource::NS){|xmsg|
			msg= Message.new 
			msg.msg=xmsg.text
			Ctxt.logger.debug("Inserting message #{msg.msg}")
			msg.level=xmsg.attributes["level"]
			msg.seq=xmsg.attributes["sequence"]
			job.messages.push(msg)		
		}
		
		job.script=Script.fromXmlElement(xscript) if xscript!=nil
		job.results=Results.fromXml(xresult) if xresult!=nil;
		job.log=xlog.attributes["href"] if xlog!=nil
		job.nicename=xnicename.text if xnicename!=nil
	
		return job
	end

end
