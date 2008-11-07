require 'fiveruns_tuneup_core'

$:.unshift File.dirname(__FILE__)
require 'fiveruns_tuneup_ramaze/controller'
require 'fiveruns_tuneup_ramaze/instrumentation/ramaze'
if defined?(::DataMapper)
  require 'fiveruns_tuneup_ramaze/instrumentation/data_mapper'
end

Fiveruns::Tuneup::STRIP_ROOT = File.dirname(__FILE__)

Fiveruns::Tuneup::Run.directory = 'tmp/tuneup/runs'
Fiveruns::Tuneup.javascripts_path = '/fiveruns_tuneup/javascripts'
Fiveruns::Tuneup.stylesheets_path = '/fiveruns_tuneup/stylesheets'
Fiveruns::Tuneup::Run.environment.update(
  :framework => 'ramaze'
)

# Copy assets
asset_root = File.join(File.dirname(__FILE__), '..', 'assets')
public_destination = File.join(Ramaze::Global.public_root, 'fiveruns_tuneup')

Ramaze::Log.dev %{Updating FiveRuns TuneUp assets in #{public_destination}}
FileUtils.mkdir Ramaze::Global.public_root rescue nil
FileUtils.rm_rf public_destination  rescue nil
FileUtils.cp_r asset_root, public_destination