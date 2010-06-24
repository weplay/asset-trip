require "spec_helper"
require "rack/test"

describe AssetTrip::Middleware do
  include Rack::Test::Methods

  setup_sandbox_app!

  def app
    AssetTrip::Middleware.new(lambda {
      [404, {"Content-Type" => "text/html"}, ["Not Found"]]
    })
  end

  it "calls down the chain if the URL root is not known" do
    response = get "/"
    response.should be_not_found
  end

  it "404s if the URL root matches but there is no subdirectory" do
    response = get "/__asset_trip__/not_found.js"
    response.should be_not_found
  end

  it "404s if the URL root is known but it can't find the file" do
    response = get "/__asset_trip__/javascripts/not_found.js"
    response.should be_not_found
  end

  it "serves Javascripts" do
    response = get "/__asset_trip__/javascripts/main.js"
    response.should be_ok
  end

  it "serves Stylesheets" do
    response = get "/__asset_trip__/stylesheets/new.css"
    response.should be_ok
  end

  it "sets the Last-Modified header" do
    path = File.join(Dir.pwd, "app", "javascripts", "main.js")
    response = get "/__asset_trip__/javascripts/main.js"
    response["Last-Modified"].should == File.mtime(path).httpdate
  end

  it "does not allow directory traversal" do
    response = get "/__asset_trip__/../main.js"
    response.should be_forbidden
  end

  it "does not allow directory traversal with encoded periods" do
    response = get "/__asset_trip__/%2E%2E/main.js"
    response.should be_forbidden
  end

  it "serves files with URL encoded filenames" do
    response = get "/__asset_trip__/javascripts/%6D%61%69%6E.js" # main.js
    response.should be_ok
  end

  it "serves Javascripts based on the JS load path" do
    AssetTrip.config.load_paths[:javascripts] = AssetTrip::LoadPath.new
    response = get "/__asset_trip__/javascripts/main.js"
    response.should be_not_found
  end

  it "serves Stylesheets based on the CSS load path" do
    AssetTrip.config.load_paths[:stylesheets] = AssetTrip::LoadPath.new
    response = get "/__asset_trip__/stylesheets/new.css"
    response.should be_not_found
  end
  
  context "when jit bundling is enabled" do
    
    it "returns a 404 when the bundle is not found in the config" do
      response = get "/__asset_trip__/bundle/stylesheets/doesnotexist.css"
      response.should be_not_found
    end
    
    it "returns a 500 when the bundle is found, but one or more of the bundle's files do not exist" do
      install_config <<-CONFIG
        js_asset "signup" do
          include "notondisk"
        end
      CONFIG
      
      response = get "/__asset_trip__/bundle/javascripts/signup.js"
      response.should be_server_error
    end
    
    it "returns 200 when bundle is found in the config" do
      install_config <<-CONFIG
        js_asset "signup" do
          include "main"
          include "signup"
        end
      CONFIG
      
      response = get "/__asset_trip__/bundle/javascripts/signup.js"
      response.should be_ok
    end
    
    it "returns the bundle's contents when the bundle is in the config" do
      install_config <<-CONFIG
        js_asset "signup" do
          include "main"
          include "signup"
        end
      CONFIG
      
      response = get "/__asset_trip__/bundle/javascripts/signup.js"
      response.body.should be_like(<<-BODY)
      alert("main");
      alert("signup");
      BODY
    end

    it "allows the use of @media types when bundling" do
      install_config <<-CONFIG
        css_asset "signup" do
          with_options :media_type => 'print' do |print|
            print.include 'new'
          end
        end
      CONFIG
      write_stylesheet("new.css", <<-STYLESHEET)
        /* Comment */
        .foo {
          font-weight: bold;
        }
      STYLESHEET
      response = get "/__asset_trip__/bundle/stylesheets/signup.css"
      response.body.should be_like(<<-OUTPUT)
@media print {
      /* Comment */
      .foo {
        font-weight: bold;
      }
}
      OUTPUT
    end
    
    context "when using ssl" do
      
      it "retrieves an ssl asset for ssl stylesheets" do
        stubbed_asset = stub()
        stubbed_ssl_stylesheet = stub(:joined_contents => "ssl_stylesheet_contents")
        stubbed_asset.should_receive(:ssl_stylesheet).and_return(stubbed_ssl_stylesheet)
        AssetTrip.config.assets_hash.stub!(:[] => stubbed_asset)
        install_config <<-CONFIG
          css_asset "all" do
            include "new"
          end
        CONFIG

        response = get "/__asset_trip__/bundle/stylesheets/all.css", {}, {'SERVER_PORT' => '443'}
        response.body.should be_like(<<-BODY)
        ssl_stylesheet_contents
        BODY
      end

      it "does not retrieve an ssl asset for non-stylesheet assets" do
        stubbed_asset = stub(:joined_contents => "foo")
        stubbed_asset.should_not_receive(:ssl_stylesheet)
        AssetTrip.config.assets_hash.stub!(:[] => stubbed_asset)
        install_config <<-CONFIG
          js_asset "signup" do
            include "main"
            include "signup"
          end
        CONFIG

        response = get "/__asset_trip__/bundle/javascripts/signup.js", {}, {'SERVER_PORT' => '443'}
      end
      
    end

  end
end
