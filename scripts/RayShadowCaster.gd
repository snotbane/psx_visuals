
@tool class_name RayShadowCaster extends RayCast3D

static var shadow_quad : QuadMesh
static func _static_init() -> void:
	shadow_quad = QuadMesh.new()
	shadow_quad.orientation = PlaneMesh.FACE_Y
	shadow_quad.material = preload("uid://20ut3o26ngws")

@export var scale_with_distance : bool = false
@export var fade_with_distance : bool = false

@export var margin : float = 0.025

var _material : Material
@export var material : Material = null :
	get: return _material
	set(value):
		if _material == value: return
		_material = value

		if mesh == null: return

		mesh.material_override = _material


var mesh : MeshInstance3D

func _init() -> void:
	mesh = MeshInstance3D.new()
	mesh.mesh = shadow_quad
	mesh.material_override = _material
	add_child(mesh)


func _process(delta: float) -> void:
	mesh.visible = is_colliding()
	if not mesh.visible: return

	var collision_percent : float = global_position.distance_squared_to(get_collision_point()) / target_position.length_squared()

	mesh.global_position = get_collision_point() + get_collision_normal() * margin
	mesh.global_basis.z = -get_collision_normal()
	mesh.transparency = collision_percent if fade_with_distance else 0.0
	mesh.scale = Vector3.ONE * (1.0 - (collision_percent if scale_with_distance else 0.0))
