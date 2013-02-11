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
	def initialize(id,output_path)
		super("/jobs",{:id=>id},StoreToFileProcessor.new(output_path))
	end	
	def buildUri
    		uri = "#{super}/result"
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

	attr_accessor :id,:status,:script,:result,:messages,:log
	def initialize(id)	
		@id=id
		@messages=[]
	end

	def to_s
		s="Job Id: #{@id}\n"
		s+="\t Status: #{@status}\n"
		s+="\t Script: #{@script.uri}\n" if @script!=nil
		s+="\t Result: #{@result}\n" if @result!=nil
		s+="\t Log: #{@log}\n" if @log!=nil
		s+="\t Messages: #{@messages.size}\n"
		s+="\n"
		return s	
	end	

end
class JobBuilder
	def fromXml(element)
		Ctxt.logger.debug("from element: #{element.to_s}")
		job=Job.new(element.attributes["id"])
		job.status=element.attributes["status"]
	
		xscript=XPath.first(element,"./ns:script",Resource::NS)
		xresult=XPath.first(element,"./ns:result",Resource::NS)
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
		job.result=xresult.attributes["href"] if xresult!=nil
		job.log=xlog.attributes["href"] if xlog!=nil
	
		return job
	end

end
