require "test/unit"
require "./test/require_rel"
require "./core/resource"
require "./core/cli"
require "./core/ctxt"
class TestResource < Test::Unit::TestCase
	def setup
		#init ctxt
		@cli=Cli.new(File.dirname('.'),"dp2 test","DP2T","0.0.0")	
	end
	def test_buildUri
		Ctxt.conf[Conf::BASE_URI]="localhost/"
		simpl=Resource.new("thing",{},nil)	
		assert_equal "localhost/thing",simpl.buildUri

	end
	def test_buildUriId
		Ctxt.conf[Conf::BASE_URI]="localhost/"
		wid=Resource.new("thing",{:id=>"me"},nil)	
		assert_equal "localhost/thing/me",wid.buildUri
	end
end
