require "active_support"

module AssetTrip
  autoload :Asset, "asset_trip/asset"
  autoload :Compressor, "asset_trip/compressor"
  autoload :Config, "asset_trip/config"
  autoload :Helper, "asset_trip/helper"
  autoload :Javascript, "asset_trip/javascript"
  autoload :LoadPath, "asset_trip/load_path"
  autoload :Manifest, "asset_trip/manifest"
  autoload :Middleware, "asset_trip/middleware"
  autoload :Memoizable, "asset_trip/memoizable"
  autoload :Stylesheet, "asset_trip/stylesheet"
  autoload :UrlRewriter, "asset_trip/url_rewriter"

  class CompressorError < StandardError
  end

  class UnknownAssetError < StandardError
  end

  def self.bundle!
    config.bundle!
  end

  def self.config
    Config.from_file(config_path)
  end

  def self.manifest
    @manifest
  end

  def self.app_root
    Pathname.new(".").expand_path
  end

  def self.root
    Pathname.new(__FILE__).dirname.join("..").expand_path
  end

  def self.config_path
    app_root.join("config", "asset_trip")
  end

end