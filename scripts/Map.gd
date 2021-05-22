extends StaticBody

onready var hero = get_node('/root/World/Hero')



func _on_Map_input_event(camera, event, click_position, click_normal, shape_idx):
		if event is InputEventMouseButton and event.pressed:
			var t:Vector3 = click_position
		
			hero.target = t
			print(hero)
