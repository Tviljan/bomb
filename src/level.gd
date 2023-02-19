extends Node3D

@onready var bomb = preload("res://nodes/bomb/bomb.tscn")
@onready var player_scene = preload("res://player/cubio.tscn")

@onready var gridmap : GridMap = $GridMap
@onready var explosion = preload("res://nodes/explosion/explosion.tscn")
@onready var random_object = preload("res://nodes/pickable/random_object.tscn")
@onready var breakable = preload("res://nodes/bricks/breakable.tscn")

  
var grid_width = 16
var grid_height = 12

var _tile_offset = Vector3(.5,0,.5)

func _ready():
	var player = player_scene.instantiate() as CharacterBody3D
	player.global_position = Vector3(2,1.5,2)
	player.scale = Vector3(.8, .8, .8)
	player.connect("drop_bomb", _on_player_drop_bomb)
	add_child(player)
	
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
	add_unbreakables()
	var r = random_object.instantiate()
	r.global_position = Vector3(9.5,1.5,10.5)
	add_child(r)

func add_unbreakables():
	
	for h in range(1,grid_height):		
		for w in range(1,grid_width):
			if fmod(h, 2) == 0 and fmod(w,2) == 0:
				gridmap.set_cell_item(Vector3(w,1,h),1)
				
			
func add_breakables():
	var locations = [Vector3(0,1.5,4),
		Vector3(1,1.5,4),
		Vector3(2,1.5,4),
		Vector3(3,1.5,4),
		Vector3(4,1.5,4),
		Vector3(5,1.5,4),
		Vector3(6,1.5,4),
		Vector3(7,1.5,4),
		Vector3(8,1.5,4),
		Vector3(9,1.5,4),
		Vector3(10,1.5,4),
		Vector3(11,1.5,4),
		Vector3(12,1.5,4),
		Vector3(13,1.5,4),
		Vector3(14,1.5,4),
		Vector3(15,1.5,4),
		Vector3(0,1.5,6),
		Vector3(1,1.5,6),
		Vector3(2,1.5,6),
		Vector3(3,1.5,6),
		Vector3(4,1.5,6),
		Vector3(5,1.5,6),
		Vector3(6,1.5,6),
		Vector3(7,1.5,6),
		Vector3(8,1.5,6),
		Vector3(9,1.5,6),
		Vector3(10,1.5,6),
		Vector3(11,1.5,6),
		Vector3(12,1.5,6),
		Vector3(13,1.5,6),
		Vector3(14,1.5,6),
		Vector3(15,1.5,6)]
		
		
	for i in locations:
		var b = breakable.instantiate()
		b.global_position =i + _tile_offset
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
		var instance = bomb.instantiate()
		
		instance.connect("on_explode", _on_bomb_explode)
		instance.global_position = Vector3(hovered_point.x + 0.5, hovered_point.y, hovered_point.z + 0.5)

		player.add_collision_exception_with(instance)
		add_child(instance)
	
