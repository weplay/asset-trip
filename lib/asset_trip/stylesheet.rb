module AssetTrip
  class Stylesheet < Asset
    EMPTY_STRING = ''.freeze
    def name
      "#{@name}.css"
    end

    def ssl_stylesheet
      SSLStylesheet.new(@config, @name, [], @asset_files.map{ |f| f.clone })
    end

    def joined_contents
      @asset_files.map do |file|
        preamble(file) + url_rewriter(file.path).rewrite(File.read(file.path)) + postamble(file)
      end.join("\n\n")
    end

  private

    def compressor
      Compressor.new("css")
    end

    def url_rewriter(filesystem_path)
      public_path = AssetTrip.app_root.join("public")

      if filesystem_path.to_s.starts_with?(public_path)
        public_path = Pathname.new("/").join(filesystem_path.relative_path_from(public_path))
        UrlRewriter.new(url_scheme, public_path)
      else
        UrlRewriter.new(url_scheme)
      end
    end
    
    def preamble(asset_file)
      if asset_file.specifies_media_type?
        "@media #{asset_file.media_type} {\n"
      else
        EMPTY_STRING
      end
    end

    def postamble(asset_file)
      if asset_file.specifies_media_type?
        "\n}"
      else
        EMPTY_STRING
      end
    end

    def asset_type
      :stylesheets
    end

    def url_scheme
      "http"
    end

    def extension
      ".css"
    end

  end
end
