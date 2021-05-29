tool extends Spatial

export var remote_path:NodePath
export var y:int
export var margin:Vector2 = Vector2.ZERO

func _process(_delta: float) -> void:
	if Engine.editor_hint:
		return
		
	if !is_inside_tree():
		return
		
	var viewport:Viewport = get_viewport()
	if !is_instance_valid(viewport):
		return

	var camera:Camera = viewport.get_camera()
	if !is_instance_valid(camera) or camera.get_parent() != self:
		return

	var target:Spatial = get_node_or_null(remote_path)
	if !is_instance_valid(target):
		return

	var viewport_center := viewport.size * 0.5
	var target_position := target.global_transform.origin
	var position_3d := Vector3(target_position.x, y, target_position.z)
	var position_2d := camera.unproject_position(position_3d)
	var off_center := position_2d - viewport_center
	var off_center_clamped := Vector2(
			clamp(off_center.x, -margin.x, margin.x),
			clamp(off_center.y, -margin.y, margin.y)
		)

	if off_center == off_center_clamped:
		return

	var target_2d := viewport_center + off_center - off_center_clamped
	var ray_origin := camera.project_ray_origin(target_2d)
	var ray_direction := camera.project_ray_normal(target_2d)
	var depth := (y - ray_origin.y) / ray_direction.y
	var target_3d := ray_origin + ray_direction * depth # camera.project_position(_target_2d, depth)
	global_transform = Transform.IDENTITY.translated(target_3d)

func _get_configuration_warning() -> String:
	var target = get_node_or_null(remote_path) as Spatial
	if !is_instance_valid(target):
		return "The \"Remote Path\" property must point to a valid Spatial or Spatial-derived node to work."

	return ""
