extends CanvasLayer

func _init() -> void:
	layer = RenderingServer.CANVAS_LAYER_MIN

	var material := ShaderMaterial.new()
	material.shader = preload("uid://f30u05sxx1vk")

	var color_rect := ColorRect.new()
	color_rect.material = material
	color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)

	add_child(color_rect)
