require "test/unit"
require 'test/unit/testsuite'
require 'test/unit/ui/console/testrunner'

require "test/command/conf_parser_test"
require "test/core/cli_test"
require "test/core/client_test"
require "test/core/resource_test"
require "test/core/result_processor_test"

class TS_AllTests
	def self.suite
		suite = Test::Unit::TestSuite.new("Cli tests")
		suite << TestConfParser.suite 
		suite << TestCli.suite 
		suite << TestClient.suite
		suite << TestResource.suite
		suite << TestResultProcessor.suite
		return suite
	end
end
Test::Unit::UI::Console::TestRunner.run(TS_AllTests)

