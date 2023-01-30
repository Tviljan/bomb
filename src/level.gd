extends Node3D

@onready var scene = preload("res://bomb.tscn")
@onready var gridmap : GridMap = $GridMap
func _ready():
	$Cubio.connect("drop_bomb", _on_player_drop_bomb)

func _on_player_drop_bomb(player : CharacterBody3D):
	
	var ray = player.get_node("RayCast3D") as RayCast3D

	if (ray != null):
		var collision = ray.get_collision_point()
		
		var hovered_point = gridmap.local_to_map(collision)
		var hovered_tile = gridmap.get_cell_item(hovered_point)
		var instance = scene.instantiate()
		
		instance.global_position = Vector3(hovered_point.x + 0.5, hovered_point.y, hovered_point.z + 0.5)

		player.add_collision_exception_with(instance)
		add_child(instance)
	
