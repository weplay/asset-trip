require "asset_trip"

Dir[File.join(File.dirname(__FILE__), 'support', '*.rb')].each do |file|
  require file
end

class DummyCompressor
  def compress(contents)
    return contents
  end
end

Spec::Runner.configure do |config|
  config.include AssetTrip::Spec::Helpers
  config.include AssetTrip::Spec::Matchers
  config.include AssetTrip::Spec::PathUtils
  config.extend  AssetTrip::Spec::SandboxHelper

  config.before do
    reset_asset_trip
  end
end
