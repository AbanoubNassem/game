extends KinematicBody


export var speed = 5
export var gravity = -5

var target = transform.origin
var velocity = Vector3.ZERO

func _physics_process(delta):
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector3.UP)
	if is_on_floor():
		var h_distance = Vector2(transform.origin.x, transform.origin.z).distance_to(Vector2(target.x, target.z))
		if Input.is_action_pressed("Jump"):
			var expected_time = h_distance / speed
			var v_velocity = -0.5 * expected_time * gravity
			velocity.y = v_velocity
		if h_distance < 0.5:
			# perhaps you want to flip this line, maybe just set x and z
			transform.origin =  target
			velocity = Vector3(0, velocity.y, 0)
		else:
			look_at(target, Vector3.UP)
			rotation.x = 0
			var vel = -transform.basis.z * speed
			velocity = Vector3(vel.x, velocity.y, vel.z)
