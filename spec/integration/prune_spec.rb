require "spec_helper"

describe "rake asset_trip:prune" do
  setup_sandbox_app!(:each)

  before do
    AssetTrip::Compressor.stub!(:new => DummyCompressor.new)
  end

  it "removes assets not in the current Manifest" do
    install_config <<-CONFIG
      js_asset "signup" do
        include "main.js"
      end
    CONFIG
    AssetTrip.bundle!
    AssetTrip.instance_variable_set(:@config, nil)
    write_javascript("main.js", 'alert("new.main");')
    AssetTrip.bundle!
    load_manifest
    AssetTrip.prune!
    assets("signup.js").should have(1).item
  end


  describe "removing empty directories" do
    it "removes empty directories" do
      install_config <<-CONFIG
        js_asset "signup" do
          include "main.js"
        end
      CONFIG
      AssetTrip.bundle!
      
      empty_dir = assets_path.join("testing")
      Dir.mkdir(empty_dir)
      
      load_manifest
      
      AssetTrip.prune!
      assets_path.should_not have_directory(empty_dir)
    end
    
    it "removes nested directories that are empty" do
      install_config <<-CONFIG
        js_asset "signup" do
          include "main.js"
        end
      CONFIG
      AssetTrip.bundle!

      require 'fileutils'
      FileUtils.mkdir_p assets_path.join("testing").join("subdirectory")

      load_manifest
      
      AssetTrip.prune!
      assets_path.should_not have_directory(assets_path.join("testing"))
    end
  end

  it "does not remove assets in the current Manifest" do
    install_config <<-CONFIG
      js_asset "signup" do
        include "main.js"
      end
    CONFIG
    AssetTrip.bundle!
    load_manifest
    AssetTrip.prune!
    assets("signup.js").should have(1).item
  end

  it "removes unknown files" do
    install_config <<-CONFIG
      js_asset "signup" do
        include "main.js"
      end
    CONFIG
    AssetTrip.bundle!

    File.open(assets_path.join("blah.jpg"), "w") do |f|
      f << "blah!"
    end

    load_manifest
    AssetTrip.prune!
    assets("blah.jpg").should have(0).items
  end
end
