require "test/unit"
require "test/require_rel"
require "commands/conf_parser"
require "core/conf"
require "core/ctxt"

class TestConfParser< Test::Unit::TestCase
	def setup
		Ctxt.conf("config.yml")
		Ctxt.conf[Conf::PORT]=8181
	end
	def teardown
		
		Ctxt.conf[Conf::PORT]=8181
	end

	def test_clean
		parser=ConfParser.new
		args=["cosa","-l","--port","8080"]
		clean=parser.cleanSwitches(args)

		assert_not_nil clean.find_index("cosa")
		assert_not_nil clean.find_index("+l")
		assert_not_nil clean.find_index("--port")
		assert_not_nil clean.find_index("8080")
		
	end
	def test_revert
		parser=ConfParser.new
		args=["cosa","+l","--port","8080"]
		clean=parser.revertSwitches(args)

		assert_not_nil clean.find_index("cosa")
		assert_not_nil clean.find_index("-l")
		assert_not_nil clean.find_index("--port")
		assert_not_nil clean.find_index("8080")
		
	end
	def test_parse
		parser=ConfParser.new
		args=["cosa","-l","--port","8080"]
		Ctxt.conf[Conf::PORT]="8181"	
		Ctxt.conf.update_vals
		assert_equal Ctxt.conf[Conf::PORT],"8181"
		parser.parse(args)
		assert_equal Ctxt.conf[Conf::PORT],"8080"

		
	end
end
