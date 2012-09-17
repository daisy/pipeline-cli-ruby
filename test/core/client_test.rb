require "test/unit"
require "test/require_rel"
require "core/client"
require "core/result_processor"
require "rexml/document"
require "rexml/xpath"
include REXML
class TestClient < Test::Unit::TestCase
	def test_clientBuilder
		file=File.new("../framework/webservice/samples/xml-formats/client.xml")
		xml=REXML::Document.new file
		cliXml=REXML::XPath.first(xml,"./ns:client",Resource::NS)
		client=ClientBuilder.new.fromXml(cliXml)
		assert_equal client.id,"clientid"
		assert_equal client.secret,"thesecret"
		assert_equal client.role,"ADMIN"
		assert_equal client.contact,"me@example.org"
		assert_equal client.href,"http://example.org/ws/admin/clients/clientid"
	end
	def test_clientToXml
		client=Client.new

		client.id="clientid"
		client.secret="thesecret"
		client.role="ADMIN"
		client.contact="me@example.org"
		client.href="http://example.org/ws/admin/clients/clientid"
		cliXml=ClientBuilder.new.toXml(client)
		client=ClientBuilder.new.fromXml(cliXml.root)
		assert_equal client.id,"clientid"
		assert_equal client.secret,"thesecret"
		assert_equal client.role,"ADMIN"
		assert_equal client.contact,"me@example.org"
		assert_equal client.href,"http://example.org/ws/admin/clients/clientid"
	end
end
