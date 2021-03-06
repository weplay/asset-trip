require "action_controller"
require "action_view"
require "ostruct"
require "uri"

module AssetTrip
  class UrlRewriter
    include ActionView::Helpers::AssetTagHelper

    def initialize(scheme, stylesheet_path = nil)
      @scheme = scheme
      @stylesheet_path = stylesheet_path

      setup_fake_controller_for_asset_host_computation
    end

    def rewrite(contents)
      contents.gsub(/url *\(([^\)]+)\)/) do
        "url(#{add_asset_host_to_path($1)})"
      end
    end

  private

    def setup_fake_controller_for_asset_host_computation
      environment = {}
      environment["HTTPS"] = "on" if @scheme == "https"
      @controller = OpenStruct.new(:request => ActionController::Request.new(environment)) # Used by Rails compute_asset_host method from ActionView::Helpers::AssetTagHelper
    end

    def add_asset_host_to_path(path)
      strip_quotes!(path)

      if prepend_asset_host?(path)
        path = rewrite_relative_path(path) unless @stylesheet_path.blank?
        URI::Generic.build(uri_components(path.to_s)).to_s
      else
        path
      end
    end

    def uri_components(path)
      opts = { :path => path }

      if (asset_id = rails_asset_id(path)).present?
        opts[:query] = asset_id
      end

      if (host = compute_asset_host(path)).present?
        opts[:port]   = strip_port(host)
        opts[:host]   = strip_scheme(host)
        opts[:scheme] = @scheme
      end

      return opts
    end

    def rewrite_relative_path(relative_url)
      if relative_url.starts_with?("/")
        return relative_url
      else
        Pathname.new(File.join(@stylesheet_path.dirname, relative_url)).cleanpath
      end
    end

    def prepend_asset_host?(path)
      uri = URI.parse(path)

      uri.relative? &&
      File.extname(uri.path) != '.htc'
    end

    def strip_port(host)
      port = nil
      host.gsub!(/:(\d+)/) do
        port = $1
        ''
      end
      port
    end
    
    def strip_scheme(host)
      host.gsub(/^[a-z]+:\/\//, '')
    end

    def strip_quotes!(path)
      path.gsub!(/^\s*['"]*/, "")
      path.gsub!(/['"]*\s*$/, "")
    end

  end
end
