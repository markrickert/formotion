require File.expand_path(File.join(File.dirname(__FILE__), "formotion/version"))
require 'bubble-wrap/core'
require 'bubble-wrap/font'
require 'bubble-wrap/camera'

Motion::Project::App.setup do |app|
  core_lib = File.join(File.dirname(__FILE__), 'formotion')
  insert_point = app.files.find_index { |file| file =~ /^(?:\.\/)?app\// } || 0

  Dir.glob(File.join(core_lib, '**/*.rb')).reverse.each do |file|
    app.files.insert(insert_point, file)
  end

  app.frameworks << 'CoreLocation' unless app.frameworks.include?('CoreLocation')
  app.frameworks << 'MapKit' unless app.frameworks.include?('MapKit')

  app.resources_dirs << File.join(File.dirname(__FILE__), '../resources')
end
