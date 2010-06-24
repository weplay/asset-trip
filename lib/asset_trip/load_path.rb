module AssetTrip
  class LoadPath

    attr_reader :paths

    def initialize(paths = [])
      @paths = paths.map { |path| Pathname.new(path) }
    end

    def ==(other)
      self.class == other.class &&
      @paths == other.paths
    end

    def <<(path)
      @paths << Pathname.new(path)
    end

    # TODO: Refactor
    def resolve(filename, opts = {})
      options = { :full_path => true }.merge(opts)
      raise UnknownAssetError.new("Could not find #{filename} in paths: #{@paths.inspect}") if filename.nil?
      file_paths = @paths.map do |path|
        options[:full_path] ? path.join(filename).expand_path : path.join(filename)
      end

      result = file_paths.detect do |file_path|
        File.exist?(file_path)
      end

      if result
        return result
      else
        raise UnknownAssetError.new("Could not find #{filename} in paths: #{@paths.inspect}")
      end
    end

  end
end
