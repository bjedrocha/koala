ROOT_DIR = File.expand_path(File.dirname(__FILE__)) unless defined? ROOT_DIR

require "rubygems"

begin
  require "vendor/dependencies/lib/dependencies"
rescue LoadError
  require "dependencies"
end

require "monk/glue"
require "ohm"
require "ohm/contrib"
require "haml"
require 'yaml'
require 'json'
require 'resque'
require 'aws/s3'
require 'lib/store/file_store'
require 'aasm'

class Main < Monk::Glue
  set :app_file, __FILE__
  use Rack::Session::Cookie
end

# Connect to redis database.
Ohm.connect(settings(:redis))

# Setup Resque to connect to redis
Resque.redis = settings(:resque_redis)

# Load all application files.
Dir[root_path("app/**/*.rb")].each do |file|
  require file
end

# Load all extensions
Dir[root_path("lib/extensions/*.rb")].each do |file|
  require file
end

# Setup video storage
Store = FileStore.new

Main.run! if Main.run?
