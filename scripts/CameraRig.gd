tool extends Spatial

export var remote_path:NodePath
export var y:int
export var margin:Vector2 = Vector2.ZERO

var _camera:Camera = null
var _viewport_center:Vector2

func _ready() -> void:
	camera_changed()
	viewport_changed()
	# warning-ignore:return_value_discarded
	connect("tree_entered", self, "viewport_changed")
	# warning-ignore:return_value_discarded
	connect("tree_exited", self, "viewport_changed")

func _process(_delta: float) -> void:
	if Engine.editor_hint:
		return

	var target = get_node_or_null(remote_path) as Spatial
	var camera = get_camera()
	if !is_instance_valid(target) or !is_instance_valid(camera):
		return # either null or freed

	var target_position = target.global_transform.origin
	var position_3d := Vector3(target_position.x, y, target_position.z)
	var position_2d:Vector2 = camera.unproject_position(position_3d)
	var off_center := position_2d - _viewport_center
	var off_center_clamped := Vector2(
			clamp(off_center.x, -margin.x, margin.x),
			clamp(off_center.y, -margin.y, margin.y)
		)

	if off_center == off_center_clamped:
		return

	var _target_2d = _viewport_center + off_center - off_center_clamped
	var ray_origin = camera.project_ray_origin(_target_2d)
	var ray_direction = camera.project_ray_normal(_target_2d)
	var depth = (y - ray_origin.y) / ray_direction.y
	var _target_3d = ray_origin + ray_direction * depth # camera.project_position(_target_2d, depth)
	global_transform = Transform.IDENTITY.translated(_target_3d)

func _get_configuration_warning() -> String:
	var target = get_node_or_null(remote_path) as Spatial
	if !is_instance_valid(target):
		return "The \"Remote Path\" property must point to a valid Spatial or Spatial-derived node to work."
	
	var camera = get_camera()
	if !is_instance_valid(camera):
		return "The node has no Camera. Add a Camera or Camera-derived child node."
	
	return ""

func get_camera() -> Camera:
	if !is_instance_valid(_camera):
		camera_changed()

	return _camera

func camera_changed() -> void:
	if !is_inside_tree():
		_camera = null
		return

	_camera = find_child_camera()
	if !is_instance_valid(_camera):
		return

	if !_camera.is_connected("tree_exited", self, "camera_changed")\
	and _camera.connect("tree_exited", self, "camera_changed", [], CONNECT_ONESHOT) != OK:
		push_error("Failed to connect Camera")

func find_child_camera() -> Camera:
	for child in get_children():
		if child is Camera:
			return child

	return null

func viewport_changed() -> void:
	if !is_inside_tree():
		_viewport_center = Vector2.ZERO
		return

	var viewport:Viewport = get_viewport()
	if !is_instance_valid(viewport):
		_viewport_center = Vector2.ZERO
		return

	if !viewport.is_connected("size_changed", self, "viewport_changed")\
	and viewport.connect("size_changed", self, "viewport_changed", [], CONNECT_ONESHOT) != OK:
		push_error("Failed to connect Viewport")

	if !viewport.is_connected("tree_exited", self, "viewport_changed")\
	and viewport.connect("tree_exited", self, "viewport_changed", [], CONNECT_ONESHOT) != OK:
		push_error("Failed to connect Viewport")

	_viewport_center = viewport.size * 0.5
