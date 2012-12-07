require "test/unit"
require "./test/require_rel"
require "./core/resource"
require "./core/result_processor"
require "rexml/document"
include REXML

class Thing
	attr_accessor :stuff
	def fromXml(element)
		thing= Thing.new
		thing.stuff=element.attributes["stuff"]
		return thing
	end
end
class TestResultProcessor < Test::Unit::TestCase
	def test_list_result_processor
		
		lrp=ListResultProcessor.new( "//ns:thing" ,Thing.new) 
		xmlstr = '<things xmlns="http://www.daisy.org/ns/pipeline/data"><thing stuff="1"/><thing stuff="2"/></things>'
		list=lrp.process(xmlstr)	
		assert_equal 2,list.size
		assert_equal list[0].stuff,"1"
		assert_equal list[1].stuff,"2"
	end
	def test_err_list_result_processor
		
		lrp=ListResultProcessor.new( "//ns:thing" ,Thing.new) 
		assert_raise RuntimeError do
			list=lrp.process nil	
		end

		assert_raise RuntimeError do
			list=lrp.process("")	
		end
		
	end
end
