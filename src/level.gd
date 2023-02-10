extends Node3D

@onready var scene = preload("res://bomb.tscn")
@onready var gridmap : GridMap = $GridMap
@onready var explosion = preload("res://models/explosion.tscn")
@onready var random_object = preload("res://random_object.tscn")
@onready var breakable = preload("res://breakable.tscn")

var grid_width = 16
var grid_height = 12

func _ready():
	$Cubio.connect("drop_bomb", _on_player_drop_bomb)

	#Ground
	for x in range(0,grid_width):
		for z in range(0,grid_height):
			gridmap.set_cell_item(Vector3(x,0,z),0)
			
	#Walls
	for z in range(-1,grid_height + 1):
		gridmap.set_cell_item(Vector3(-1,1,z),0)
		gridmap.set_cell_item(Vector3(grid_width,1,z),0)
		
	for x in range(0,grid_width):
		gridmap.set_cell_item(Vector3(x,1,-1),0)
		gridmap.set_cell_item(Vector3(x,1,grid_height),0)
		
	add_breakables()

	var r = random_object.instantiate()
	r.global_position = Vector3(9.5,1.5,10.5)
	add_child(r)
		
func add_breakables():
	var locations = [Vector3(10.5,1.5,10.5),
		Vector3(11.5,1.5,10.5),
		Vector3(4.5,1.5,4.5),
		Vector3(5.5,1.5,4.5),
		Vector3(6.5,1.5,4.5),
		Vector3(7.5,1.5,4.5),
		Vector3(4.5,1.5,4.5),
		Vector3(5.5,1.5,5.5),
		Vector3(6.5,1.5,6.5),
		Vector3(7.5,1.5,7.5)]
		
		
	for i in locations:
		var b = breakable.instantiate()
		b.global_position =i
		add_child(b)
			
func _on_bomb_explode(bomb_location : Vector3, bomb_size : int):
	var e = explosion.instantiate()
	e.explosion_size = bomb_size
	e.global_position = bomb_location + Vector3.UP * .5
	add_child(e)

func _on_player_drop_bomb(player : CharacterBody3D):
	
	var ray = player.get_node("RayCast3D") as RayCast3D

	if (ray != null):
		var collision = ray.get_collision_point()
		
		var hovered_point = gridmap.local_to_map(collision)
		var hovered_tile = gridmap.get_cell_item(hovered_point)
		var instance = scene.instantiate()
		instance.connect("on_explode", _on_bomb_explode)
		instance.global_position = Vector3(hovered_point.x + 0.5, hovered_point.y, hovered_point.z + 0.5)

		player.add_collision_exception_with(instance)
		add_child(instance)
	
