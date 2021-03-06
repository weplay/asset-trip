require "digest"

module AssetTrip
  class Asset
    extend Memoizable

    attr_reader :asset_files

    def initialize(config, name, filenames = [], asset_files = [], &block)
      @config = config
      @name = name
      @asset_files = asset_files
      @asset_files.concat(filenames.map{ |f| AssetFile.new(self, f) })

      instance_eval(&block) if block_given?
      raise AssetTrip::InvalidAssetError, "#{asset_type.to_s.singularize} asset '#{name}' does not contain any files" if @asset_files.empty?
    end
    
    def bundle!
      if expired?
        puts "Rebundling #{name}..." if ENV["VERBOSE"]
        FileWriter.new(path).write!(contents)
        puts "Finished rebundling #{name}" if ENV["VERBOSE"]
      end
    end

    def contents
      compressor.compress(joined_contents)
    end
    memoize :contents

    def paths
      asset_files.map do |file|
        file.path
      end
    end
    memoize :paths

    def path_md5sum
      relative_paths = asset_files.map { |file| @config.resolve_file(asset_type, file.filename, :full_path => false) }
      Digest::MD5.hexdigest(relative_paths.sort.join(":"))
    end
    memoize :path_md5sum

    def md5sum
      if expired?
        Digest::MD5.hexdigest(contents)
      else
        File.dirname(last_package).to_s.last(12).gsub("/", "")
      end
    end
    memoize :md5sum
    
    def resolve_path(filename)
      @config.resolve_file(asset_type, filename)
    end

  private
      
    def last_package
      packaged_files.sort_by { |path| File.mtime(path) }.last
    end

    def expired?
      ENV["FORCE"] || packaged_files.empty? || file_listing_changed? || generated_at <= last_change_at
    end

    def file_listing_changed?
      path_md5sum != AssetTrip.manifest.paths[name]
    end

    def generated_at
      packaged_file_mtimes.last
    end

    def packaged_file_mtimes
      @packaged_file_mtimes ||= packaged_files.map { |path| File.mtime(path) }.sort
    end

    def packaged_files
      Dir[AssetTrip.assets_path.join("**", name)]
    end

    def last_change_at
      mtimes.last
    end

    def mtimes
      @mtimes ||= paths.map { |path| File.mtime(path) }.sort
    end

    def include(name, options = {})
      name += extension unless name.ends_with?(extension)
      asset_files << AssetFile.new(self, name, options)
    end

    def path
      dir.join(name)
    end

    def dir
      part1 = md5sum[0..1]
      part2 = md5sum[2..10]
      AssetTrip.assets_path.join(part1, part2)
    end

  end
end
