require_rel './core/ctxt'
module Helpers 

  	module_function
	def normalise_name(str) 
		if str != nil
			str=str.downcase
			str=str.gsub(/\s/,'-')
		else
			Ctxt.logger.warning("name is nil")
		end
		return str
	end
		
	def path_to_uri(path,is_local)
		Ctxt.logger.debug("transforming path uri")
		if is_local	
			uri=File.expand_path(path).gsub(/\\/,'/')
			uri='/'+uri if uri[0]!='/'[0]
			uri="file:"+uri
					
		else
			uri=path.gsub(/\\/,'/')
		end
		Ctxt.logger.debug("uri: #{uri}")
		return URI.escape(uri)
	end

        def last_id_file
                if (Object::RUBY_PLATFORM =~ /darwin/i) != nil
                        path=File.join(Dir.home(), "Library","Application Support","DAISY Pipeline 2","dp2","lastid")
                elsif ENV["OCRA_EXECUTABLE"]!=nil
                        path=File.join(ENV["APPDATA"],"DAISY Pipeline 2","dp2","lastid")
                else
                        path=File.join(Dir.home(), ".daisy-pipeline","dp2", "lastid")
                end

                return path

        end

	def last_id_store(job)
                path=last_id_file()
                FileUtils.mkdir_p(File.dirname(path)) unless Dir.exists?(File.dirname(path))

		Ctxt.logger.debug("writing id to #{path}")
		File.open(path, 'w') {|f| f.write(job.id) }
	end

	def last_id_read
                path= last_id_file
		id=""
		if File.exists?(path)
			f=File.open(path, 'r') 
			id=f.gets() 
			f.close
		else
			Ctxt.logger.warn("path not found #{path}")
		end
		return id
	end
end
