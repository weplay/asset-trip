module AssetTrip
  module Helper

    def javascript_include_asset(*sources)
      _javascripts_for_sources(sources).map do |javascript|
        javascript_include_tag(javascript)
      end.join("\n")
    end

    def javascript_asset_url(source)
      if AssetTrip.bundle
        AssetTrip.manifest.path_for(_source_with_extension(source, ".js"))
      else
        _jit_asset_url(:javascripts, _source_with_extension(source, ".js"))
      end
    end

    def stylesheet_link_asset(*sources)
      options = sources.extract_options!

      _stylesheets_for_sources(sources).map do |stylesheet|
        stylesheet_link_tag(stylesheet, options)
      end.join("\n")
    end

    def rewrite_asset_path(source)
      if source =~ /assets/
        source
      else
        super
      end
    end

  private

    def _stylesheets_for_sources(sources)
      sources.map { |source| _stylesheets_for_source(source) }.flatten
    end

    def _javascripts_for_sources(sources)
      sources.map { |source| _javascripts_for_source(source) }.flatten
    end

    def _stylesheets_for_source(source)
      if AssetTrip.bundle
        _stylesheet_manifest_url(source)
      elsif _jit_bundle?
        _jit_asset_url(:stylesheets, _source_with_extension(source, ".css"))
      else
        _unbundled_stylesheet_urls(source)
      end
    end

    def _javascripts_for_source(source)
      if AssetTrip.bundle
        AssetTrip.manifest.path_for(_source_with_extension(source, ".js"))
      elsif _jit_bundle?
        _jit_asset_url(:javascripts, _source_with_extension(source, ".js"))
      else
        _unbundled_javascript_urls(source)
      end
    end

    def _unbundled_stylesheet_urls(source)
      asset = AssetTrip.config.assets_hash[_source_with_extension(source, ".css")]

      asset.files.map do |file|
        _unbundled_asset_url(:stylesheets, file)
      end
    end

    def _unbundled_javascript_urls(source)
      asset = AssetTrip.config.assets_hash[_source_with_extension(source, ".js")]

      asset.files.map do |file|
        _unbundled_asset_url(:javascripts, file)
      end
    end

    def _unbundled_asset_url(asset_type, file)
      "#{request.protocol}#{request.host}:#{request.port}/__asset_trip__/#{asset_type}/#{file}"
    end
    
    def _jit_asset_url(asset_type, file)
      "#{request.protocol}#{request.host}:#{request.port}/__asset_trip__/bundle/#{asset_type}/#{file}"
    end

    def _stylesheet_manifest_url(source)
      source_with_extension = _source_with_extension(source, ".css")
      if request.ssl? 
        source_with_extension = source_with_extension.gsub!(/.css$/, ".ssl.css")
      end
      AssetTrip.manifest.path_for(source_with_extension)
    end

    def _source_with_extension(source, extension)
      File.basename(source.to_s, extension) + extension
    end

    def _jit_bundle?
      _set_jit_bundle_session
      !session[:at_bundle].nil? && session[:at_bundle]
    end
    
    def _set_jit_bundle_session
      session[:at_bundle] = params[:at_bundle] == "true" if !params[:at_bundle].nil?
    end

  end
end
