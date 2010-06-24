module AssetTrip
  class AssetFile
    extend Memoizable

    attr_accessor :filename
    EMPTY_HASH = {}
  
    def initialize(asset, filename, options = EMPTY_HASH)
      @asset = asset
      @filename = filename
      @options = options
    end
  
    def path
      @asset.resolve_path(@filename)
    end
    memoize :path
    
    def specifies_media_type?
      !@options[:media_type].nil?
    end

    def media_type
      @options[:media_type]
    end
  end
end