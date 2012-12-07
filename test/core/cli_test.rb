require "minitest/unit"
require "./test/require_rel"
require "./core/cli"
require "./core/conf"
require "./core/ctxt"
class TestCli< MiniTest::Unit::TestCase
	def setup
		@cli=Cli.new(File.dirname('.'),"dp2 test","DP2T","0.0.0")	
	end
	def test_init
		#after set up that should be init
		assert_equal Ctxt.conf[Conf::PROG_NAME],"dp2 test"	
		assert_equal "DP2T",Ctxt.conf[Conf::SHORT_NAME]
		assert_equal Ctxt.conf[Conf::BASE_DIR],File.dirname('.')
		assert_equal Ctxt.conf[Conf::VERSION],"0.0.0"
	end
	def test_check_args_empy
		cmd=@cli.checkArgs([])
		assert_equal nil,cmd
	end
	def test_check_args
		cmd,args=@cli.checkArgs([ "hola","-l"])
		assert_equal "hola",cmd
	end
end
