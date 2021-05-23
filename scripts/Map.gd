extends StaticBody

export var hero_path:NodePath
onready var hero = get_node(hero_path)

func _on_Map_input_event(camera, event, click_position, click_normal, shape_idx):
		if event is InputEventMouseButton and event.pressed:
			var t:Vector3 = click_position
			$TargetIndicator.global_transform.origin = t
			hero.target = t
			print(hero)
