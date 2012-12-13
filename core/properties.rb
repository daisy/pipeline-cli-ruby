require_rel './core/ctxt'
require_rel './core/resource'
require_rel "./core/result_processor"

class PropertiesResource < Resource
	def initialize()
			super("/admin/properties",{},PropertiesResultProcessor.new)
	end	
end
class PropertiesResultProcessor< ListResultProcessor
	def initialize
		super("//ns:property",PropertyBuilder.new)
	end
end

class Property

	attr_accessor :bundleId,:bundleName,:name,:value
	def initialize
		@bundleId=""
		@bundleName=""
		@name=""
		@value=""
	end
	def to_s
		s="#{@name}: #{@value} [ From bundle #{@bundleName} (#{@bundleId})]"
	end
end
class PropertyBuilder
	NS=Resource::NS["ns"]
	E_PROPERTY='property'
	A_BUNDLE_ID='bundleId'
	A_BUNDLE_NAME='bundleName'
	A_NAME='name'
	A_VALUE='value'
	def fromXml(element)
		Ctxt.logger.debug("property from xml: #{element.to_s}")
		property= Property.new
		property.name=element.attributes[A_NAME]
		property.value=element.attributes[A_VALUE]
		property.bundleName=element.attributes[A_BUNDLE_NAME]
		property.bundleId=element.attributes[A_BUNDLE_ID]
		return property 
	end
end
