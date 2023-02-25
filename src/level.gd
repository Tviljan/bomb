extends Node3D

@onready var bomb = preload("res://nodes/bomb/bomb.tscn")


@onready var gridmap : GridMap = $GridMap
@onready var explosion = preload("res://nodes/explosion/explosion.tscn")
@onready var bigger_explosion_pickable = preload("res://nodes/pickable/bigger_explosion.tscn")
@onready var extra_bomb_pickable = preload("res://nodes/pickable/extra_bomb.tscn")
@onready var breakable = preload("res://nodes/bricks/breakable.tscn")

@onready var smoke = preload("res://nodes/smoke.tscn")

@onready var shaker = $Shaker
@onready var camera : Camera3D = $Camera3D

var grid_width = 16
var grid_height = 13

var _tile_offset = Vector3(.5,0,.5)
func _process(delta: float) -> void:
	player_manager.handle_join_input()
	
@onready var player_manager = $PlayerManager

# map from player integer to the player node
var player_nodes = {}

func _ready():
	player_manager.player_joined.connect(spawn_player)
	player_manager.player_left.connect(delete_player)

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


func add_starting_position():
	#left top player 1
	gridmap.set_cell_item(Vector3(1,1,0),3)	
	
	gridmap.set_cell_item(Vector3(0,1,1),3)
	gridmap.set_cell_item(Vector3(1,1,1),3)
	gridmap.set_cell_item(Vector3(2,1,1),3)	
	
	gridmap.set_cell_item(Vector3(1,1,2),3)
	
	
	#left center player 2
	gridmap.set_cell_item(Vector3(1,1,5),3)	
	
	gridmap.set_cell_item(Vector3(0,1,6),3)
	gridmap.set_cell_item(Vector3(1,1,6),3)
	gridmap.set_cell_item(Vector3(2,1,6),3)	
	
	gridmap.set_cell_item(Vector3(1,1,7),3)
	
	#left bottom player 3
	gridmap.set_cell_item(Vector3(1,1,10),3)	
	
	gridmap.set_cell_item(Vector3(0,1,11),3)
	gridmap.set_cell_item(Vector3(1,1,11),3)
	gridmap.set_cell_item(Vector3(2,1,11),3)	
	
	gridmap.set_cell_item(Vector3(1,1,12),3)
	
	#right top player 4
	gridmap.set_cell_item(Vector3(14,1,0),3)	
	
	gridmap.set_cell_item(Vector3(13,1,1),3)	
	gridmap.set_cell_item(Vector3(14,1,1),3)
	gridmap.set_cell_item(Vector3(15,1,1),3)
	
	gridmap.set_cell_item(Vector3(14,1,2),3)
	
	#right center player 5
	gridmap.set_cell_item(Vector3(14,1,5),3)	
	
	gridmap.set_cell_item(Vector3(13,1,6),3)	
	gridmap.set_cell_item(Vector3(14,1,6),3)
	gridmap.set_cell_item(Vector3(15,1,6),3)
	
	gridmap.set_cell_item(Vector3(14,1,7),3)
	
	
	#right bottom player 6
	gridmap.set_cell_item(Vector3(14,1,10),3)	
	
	gridmap.set_cell_item(Vector3(13,1,11),3)	
	gridmap.set_cell_item(Vector3(14,1,11),3)
	gridmap.set_cell_item(Vector3(15,1,11),3)
	
	gridmap.set_cell_item(Vector3(14,1,12),3)
	
	###
	#center top player 7
	gridmap.set_cell_item(Vector3(7,1,0),3)	
	
	gridmap.set_cell_item(Vector3(6,1,1),3)
	gridmap.set_cell_item(Vector3(7,1,1),3)
	gridmap.set_cell_item(Vector3(8,1,1),3)	
	
	gridmap.set_cell_item(Vector3(7,1,2),3)
	
	
	#center center player 8
	gridmap.set_cell_item(Vector3(7,1,5),3)	
	
	gridmap.set_cell_item(Vector3(6,1,6),3)
	gridmap.set_cell_item(Vector3(7,1,6),3)
	gridmap.set_cell_item(Vector3(8,1,6),3)	
	
	gridmap.set_cell_item(Vector3(7,1,7),3)
	
	#center bottom  9
	gridmap.set_cell_item(Vector3(7,1,10),3)	
	
	gridmap.set_cell_item(Vector3(6,1,11),3)
	gridmap.set_cell_item(Vector3(7,1,11),3)
	gridmap.set_cell_item(Vector3(8,1,11),3)	
	
	gridmap.set_cell_item(Vector3(7,1,12),3)
	
func spawn_player(player_num: int):
	#var player_scene = load("res://demo/demo_player.tscn")
	#var player_node = player_scene.instantiate()

	# create the player node	
	var player_scene = load("res://player/cubio.tscn") #player_scene.instantiate() as CharacterBody3D
	var player_node = player_scene.instantiate()
	
	player_node.global_position = Vector3(1,1.5,1)
#	player.rotate_x(1)
#
	player_node.scale = Vector3(.7, .7, .7) 
	player_node.rotation = Vector3.UP
	player_node.connect("drop_bomb", _on_player_drop_bomb)
	
	
	player_node.leave.connect(on_player_leave)
	player_nodes[player_num] = player_node
	
	# let the player know which device controls it
	var device = player_manager.get_player_device(player_num)
	player_node.init(player_num, device)
	
	# add the player to the tree
	add_child(player_node)
	

func delete_player(player: int):
	player_nodes[player].queue_free()
	player_nodes.erase(player)

func on_player_leave(player: int):
	# just let the player manager know this player is leaving
	# this will, through the player manager's "player_left" signal,
	# indirectly call delete_player because it's connected in this file's _ready()
	player_manager.leave(player)
				
func add_unbreakables():
	
	for h in range(0,grid_height):		
		for w in range(0,grid_width):
			if fmod(h, 3) == 0 and fmod(w,3) == 0:
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
	var tween = create_tween()
	add_child(e)
	tween.tween_property($Camera3D, "fov", 77, 0.01).from_current()
	tween.tween_property($Camera3D, "fov", 74, 0.01).from_current()
	tween.tween_property($Camera3D, "fov", 75, 0.01).from_current()
	
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
