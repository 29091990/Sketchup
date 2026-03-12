# DWG Material Recolor Plugin for SketchUp
# After importing a DWG file, this plugin sets all layer materials to white,
# except layers with names containing "Glass" or "Glaz" which get blue + 50% transparency.

require 'sketchup.rb'
require 'extensions.rb'

module DWG_MaterialRecolor
  PLUGIN_NAME = "DWG Material Recolor"
  PLUGIN_VERSION = "1.0.0"
  PLUGIN_DESCRIPTION = "Recolor DWG-imported layers: white for all, blue transparent for Glass/Glaz layers."

  file = __FILE__
  file = file.dup.force_encoding("UTF-8") if file.respond_to?(:force_encoding)
  PLUGIN_PATH = File.dirname(file)

  extension = SketchupExtension.new(PLUGIN_NAME, File.join(PLUGIN_PATH, "dwg_material_recolor", "main.rb"))
  extension.version = PLUGIN_VERSION
  extension.description = PLUGIN_DESCRIPTION
  extension.creator = "Custom Plugin"

  Sketchup.register_extension(extension, true)
end
