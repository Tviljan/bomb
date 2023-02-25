extends Node3D

@onready var bomb = preload("res://nodes/bomb/bomb.tscn")
@onready var player_scene = preload("res://player/cubio.tscn")

@onready var gridmap : GridMap = $GridMap
@onready var explosion = preload("res://nodes/explosion/explosion.tscn")
@onready var bigger_explosion_pickable = preload("res://nodes/pickable/bigger_explosion.tscn")
@onready var extra_bomb_pickable = preload("res://nodes/pickable/extra_bomb.tscn")
@onready var breakable = preload("res://nodes/bricks/breakable.tscn")

@onready var smoke = preload("res://nodes/smoke.tscn")
@onready var camera : Camera3D = $Camera3D

var grid_width = 16
var grid_height = 12

var _tile_offset = Vector3(.5,0,.5)
func _process(delta: float) -> void:

	var mouse_pos = camera.project_ray_origin(get_viewport().get_mouse_position())

	var mouse_dir = camera.project_ray_normal(get_viewport().get_mouse_position())
	
func _ready():

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
	
	add_starting_position()
	add_unbreakables()
	add_breakables()
#	add_pickables()

#func add_pickables():
#	var c: int = 0
#	var max = 0
#	while c < 10:
#		var w = randi() % grid_width
#		var h = randi() % grid_height
#		if gridmap.get_cell_item(Vector3(w,1,h)) == -1:
#			var v = Vector3(w+.5,1.5,h+.5)
#			print ("add object ", v)
#			var r = random_object.instantiate()
#			r.global_position = v
#			add_child(r)
#			c = c + 1
#		else:
#			max = max + 1
#			if max > 100:
#				continue
#
#			print ("blocked")

func add_starting_position():
	
	#Left corner
	gridmap.set_cell_item(Vector3(1,1,0),3)
	
	gridmap.set_cell_item(Vector3(0,1,1),3)
	gridmap.set_cell_item(Vector3(1,1,1),3)
	gridmap.set_cell_item(Vector3(2,1,1),3)
	
	gridmap.set_cell_item(Vector3(1,1,2),3)
	
	var player = player_scene.instantiate() as CharacterBody3D
	player.global_position = Vector3(1,1.5,1)
#	player.rotate_x(1)
#
	player.scale = Vector3(.7, .7, .7) 
	player.rotation = Vector3.UP
	player.connect("drop_bomb", _on_player_drop_bomb)
	add_child(player)
	
				
func add_unbreakables():
	
	for h in range(1,grid_height):		
		for w in range(1,grid_width):
			if fmod(h, 2) == 0 and fmod(w,2) == 0:
				if gridmap.get_cell_item(Vector3(w,1,h)) == -1:
					gridmap.set_cell_item(Vector3(w,1,h),1)
				
func add_breakables():
	for h in range(0,grid_height):		
		for w in range(0,grid_width):
			if gridmap.get_cell_item(Vector3(w,1,h)) == -1:
				var b = breakable.instantiate()
				b.global_position =Vector3(w,1.5,h) +_tile_offset
				b.connect("on_after_explode", _on_breakable_removed)
				add_child(b)
			else:
				print ("blocked add_breakables")
				

	
func add_preset_breakables():
	var locations = [
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
	
func _on_breakable_removed(location : Vector3):
	var s = smoke.instantiate()
	s.global_position = location
	add_child(s)
	
	await get_tree().create_timer(2).timeout
	var r = randi_range(0, 100)
	if r < 20:
		var e = extra_bomb_pickable.instantiate()
		e.global_position = location
		add_child(e)
	elif r < 40:
		var e = bigger_explosion_pickable.instantiate()
		e.global_position = location
		add_child(e)

func _on_player_drop_bomb(player : CharacterBody3D):
	
	var ray = player.get_node("RayCast3D") as RayCast3D

	if (ray != null):
		var collision = player.global_position# ray.get_collision_point()
		print ("player_position ", player.global_position)
		print ("collision_point ", collision)
		var hovered_point = gridmap.local_to_map(collision)
		var hovered_tile = gridmap.get_cell_item(hovered_point)
		var instance = bomb.instantiate()
		instance.explosion_size = player.current_bomb_size
		instance.bomb_timer = player.bomb_time_seconds
		instance.connect("on_explode", _on_bomb_explode)
		instance.global_position = Vector3(hovered_point.x + 0.5, hovered_point.y, hovered_point.z + 0.5)

		player.add_collision_exception_with(instance)
		add_child(instance)
