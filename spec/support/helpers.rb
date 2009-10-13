module BlobBundler
  module Spec
    module Helpers

      def install_js_config(config_source)
        FileUtils.mkdir_p(fixture_app)
        File.open(fixture_app("config", "blob_bundles.rb"), 'w') do |f|
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

      def bundle!
        Dir.chdir(fixture_app) do
          BlobBundler.bundle!
        end
      end

    end
  end
end