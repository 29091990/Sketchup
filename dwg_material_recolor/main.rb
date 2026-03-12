# DWG Material Recolor - Main Logic (Optimized)
# Traverses all entities ONCE, applies material based on layer lookup via Hash.
#   - Glass/Glaz layers → Blue (RGB 100, 149, 237) with 50% transparency
#   - All other layers  → White (RGB 255, 255, 255) fully opaque

module DWG_MaterialRecolor

  GLASS_PATTERNS = ["glass", "glaz"]

  def self.is_glass_layer?(layer_name)
    name_lower = layer_name.downcase
    GLASS_PATTERNS.any? { |pattern| name_lower.include?(pattern) }
  end

  def self.get_or_create_material(model, name, r, g, b, alpha)
    mat = model.materials[name]
    unless mat
      mat = model.materials.add(name)
      mat.color = Sketchup::Color.new(r, g, b)
      mat.alpha = alpha
    end
    mat
  end

  # Build a Hash: layer -> material (single pass)
  def self.build_layer_material_map(model, white_mat, glass_mat)
    layer_map = {}
    default_layer = model.layers["Layer0"]
    model.layers.each do |layer|
      next if layer == default_layer
      layer_map[layer] = is_glass_layer?(layer.name) ? glass_mat : white_mat
    end
    layer_map
  end

  # Single recursive pass over all entities
  def self.apply_materials(entities, layer_map)
    entities.each do |entity|
      mat = layer_map[entity.layer]
      if mat
        entity.material = mat if entity.respond_to?(:material=)
        entity.back_material = mat if entity.is_a?(Sketchup::Face)
      end

      # Recurse into groups / components
      if entity.is_a?(Sketchup::Group)
        apply_materials(entity.entities, layer_map)
      elsif entity.is_a?(Sketchup::ComponentInstance)
        apply_materials(entity.definition.entities, layer_map)
      end
    end
  end

  def self.run_recolor
    model = Sketchup.active_model
    unless model
      UI.messagebox("No active model found. Please open a model first.")
      return
    end

    white_mat = get_or_create_material(model, "DWG_White", 255, 255, 255, 1.0)
    glass_mat = get_or_create_material(model, "DWG_Glass_Blue", 100, 149, 237, 0.5)

    layer_map = build_layer_material_map(model, white_mat, glass_mat)

    glass_count = layer_map.values.count { |m| m == glass_mat }
    other_count = layer_map.values.count { |m| m == white_mat }

    model.start_operation("DWG Material Recolor", true)
    apply_materials(model.entities, layer_map)
    model.commit_operation

    UI.messagebox(
      "DWG Material Recolor completed!\n\n" \
      "• #{other_count} layers → White\n" \
      "• #{glass_count} layers → Blue (50% transparent)\n\n" \
      "Use Ctrl+Z to undo if needed."
    )
  end

  unless @menu_loaded
    UI.menu("Extensions").add_item("DWG Material Recolor") {
      self.run_recolor
    }
    @menu_loaded = true
  end

end
