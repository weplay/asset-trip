require "spec_helper"

describe AssetTrip::ManifestWriter do
  describe "#write!" do
    it "creates the config/asset_trip directory if necessary"
    it "writes a Ruby file"
    it "initializes @manifest in AssetTrip to be a hash"
    it "sets each asset in the hash"
    it "stores the MD5 as the value in the hash"
  end
end
