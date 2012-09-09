require "test/unit"
require "test/require_rel"
require "commands/conf_parser"
require "core/conf"
require "core/ctxt"

class TestConfParser< Test::Unit::TestCase
	def setup
		Ctxt.conf("config.yml")
	end
	def test_clean
		parser=ConfParser.new
		args=["cosa","-l","--debug","true"]
		clean=parser.cleanSwitches(args)

		assert_not_nil clean.find_index("cosa")
		assert_not_nil clean.find_index("+l")
		assert_not_nil clean.find_index("--debug")
		assert_not_nil clean.find_index("true")
		
	end
	def test_revert
		parser=ConfParser.new
		args=["cosa","+l","--debug","true"]
		clean=parser.revertSwitches(args)

		assert_not_nil clean.find_index("cosa")
		assert_not_nil clean.find_index("-l")
		assert_not_nil clean.find_index("--debug")
		assert_not_nil clean.find_index("true")
		
	end
	def test_parse
		parser=ConfParser.new
		args=["cosa","-l","--debug","true"]
		Ctxt.conf[Conf::DEBUG]="false"	
		Ctxt.conf.update_vals
		assert_equal Ctxt.conf[Conf::DEBUG],"false"
		parser.parse(args)
		assert_equal Ctxt.conf[Conf::DEBUG],"true"

		
	end
end
