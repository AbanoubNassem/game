extends Camera

onready var hero:KinematicBody = get_node('/root/World/Hero')


func _physics_process(delta):
	var pos = hero.translation
	pos.y = 0
	get_parent().translation = pos
	
