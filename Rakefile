require 'rubygems'
require 'bundler'
require './application'

Bundler.setup

Dir["#{File.dirname(__FILE__)}/rake/tasks/**/*.rake"].sort.each { |ext| load ext }
