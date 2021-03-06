module AssetTrip
  module Spec
    module Helpers

      def with_env(key, value)
        old, ENV[key] = ENV[key], value
        yield
      ensure
        old ? ENV[key] = old : ENV.delete(key)
      end

      def install_config(config_source, filename = "assets.rb")
        FileUtils.mkdir_p(fixture_app)
        File.open(fixture_app("config", "asset_trip", filename), 'w') do |f|
          f.puts config_source
        end
      end

      def write_javascript(name, contents)
        File.open(app_javascript(name), "w") do |f|
          f.puts contents
        end
      end

      def write_stylesheet(name, contents)
        File.open(app_stylesheet(name), "w") do |f|
          f.puts contents
        end
      end

      def create_asset(path, opts = {})
        fake_asset = assets_path.join(path)
        FileUtils.mkdir_p(fake_asset.dirname)
        FileUtils.touch(fake_asset)
        fake_asset.utime(opts[:mtime], opts[:mtime]) if opts[:mtime]
      end

      def reset_asset_trip
        # TODO: Is there a better way to accomodate this concern?
        AssetTrip.instance_variable_set(:@config, nil)
        AssetTrip.instance_variable_set(:@manifest, nil)
      end
      
      def load_manifest
        load manifest_path
      end

    end
  end
end
