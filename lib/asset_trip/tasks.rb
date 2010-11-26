require 'asset_trip'

if defined?(Rails) && File.exist?(Rails.root.join("config", "asset_trip", "manifest.rb"))
  require Rails.root.join("config", "asset_trip", "manifest")
end

namespace :assets do
  desc "Bundle assets"
  task :bundle => :environment do
    AssetTrip.bundle!
  end

  desc "Prune assets"
  task :prune => :environment do
    AssetTrip.prune!
  end
end