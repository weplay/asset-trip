module AssetTrip
  class Javascript < Asset

    def name
      "#{@name}.js"
    end

    def joined_contents
      paths.map do |path|
        File.read(path)
      end.join("\n\n")
    end

  private

    def compressor
      Compressor.new("js")
    end

    def asset_type
      :javascripts
    end

    def extension
      ".js"
    end

  end
end
