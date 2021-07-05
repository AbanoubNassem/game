extends KinematicBody


export var speed = 5
export var gravity = -5

onready var camera:Camera = get_node("/root/World/CameraRig/Camera")
onready var target_indicator:Position3D = get_node("/root/World/TargetIndicator")

var target = transform.origin
var velocity = Vector3.ZERO
var jump_time = 0.866667 # animation time

func _physics_process(delta):
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector3.UP)

	
	if is_on_floor():
		var h_distance = Vector2(transform.origin.x, transform.origin.z).distance_to(Vector2(target.x, target.z))
		var v_distance = target.y - transform.origin.y
		var h_velocity = speed
		var v_velocity = 0.0
		
		if Input.is_action_pressed("Jump") and h_distance > 0.5 and h_distance < 18.0:
			var jump_height = (-0.5 * jump_time * gravity) * 0.5 * jump_time + 0.125 * gravity * jump_time * jump_time
			var height = max(v_distance, 0) + jump_height
			gravity = (4 * v_distance - 8 * height) / (jump_time * jump_time)
			h_velocity = h_distance / jump_time
			v_velocity = (4 * height - v_distance) / jump_time
		if h_distance < 0.5:
			# perhaps you want to flip this line, maybe just set x and z
			target = transform.origin
			velocity = Vector3(0, v_velocity, 0)
		else:
			look_at(target, Vector3.UP)
			rotation.x = 0
			var vel = -transform.basis.z * h_velocity
			velocity = Vector3(vel.x, v_velocity, vel.z)



func _unhandled_input(event):
	if event is InputEventMouseButton:
		var position_2d = event.get_position()
		var position_3d = Vector3.ZERO
		
		var from = camera.project_ray_origin(position_2d)
		var to = from + camera.project_ray_normal(position_2d) * 100 # ray length*/;
		
		var result = get_world().direct_space_state.intersect_ray(from, to)
		
		if not result.empty():
			position_3d = result.position
			target = position_3d
			target_indicator.global_transform.origin = position_3d
		
		
		
		
		
		
		
		
		
		
		
		
