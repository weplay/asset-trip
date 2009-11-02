require "spec_helper"

describe AssetTrip::Javascript do
  describe "#contents" do
    before do
      AssetTrip::Compressor.stub!(:new => compressor)
      File.stub!(:read => "contents")
    end

    let :config do
      stub(:paths => [Pathname.new("foo.js")])
    end

    let :compressor do
      stub(:compress => "compressed")
    end

    it "compresses the contents" do
      AssetTrip::Compressor.should_receive(:new).with("js")
      asset = AssetTrip::Javascript.new(config)
      asset.contents.should == "compressed"
    end

    it "only runs the Compressor once for the package" do
      compressor.should_receive(:compress).exactly(:once)
      asset = AssetTrip::Javascript.new(config)
      asset.contents.should == "compressed"
    end
  end
end
