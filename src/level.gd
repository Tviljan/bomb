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

var player_script = load("res://player/player.gd" )	
var ai_script = load("res://player/ai.gd" )	

var grid_width = 16
var grid_height = 13

var _tile_offset = Vector3(.5,0,.5)
func _process(delta: float) -> void:
	PlayerManager.handle_join_input()

# map from player integer to the player node
var player_nodes = {}

var player_colors = [
	Color(1.0, 0.0, 0.0),  # red
	Color(1.0, 1.0, 0.0),  # yellow
	Color(0.0, 1.0, 0.0),  # green
	Color(0.0, 1.0, 1.0),  # cyan
	Color(0.0, 0.0, 1.0),  # blue
	Color(1.0, 0.0, 1.0),  # magenta
	Color(0.5, 0.0, 0.5),  # purple
	Color(0.5, 0.5, 0.0),  # olive
	Color(0.5, 0.25, 0.0)  # brown
]

var player_start_location = [
	Vector3(1.5,1.5,1.5), 
	Vector3(1.5, 1.5, 6.5),  
	Vector3(1.5, 1.5, 11.5), 
	Vector3(14.5, 1.5, 1.5), 
	Vector3(14.5, 1.5, 6.5),  
	Vector3(14.5, 1.5, 11.5),  
	Vector3(7.5, 1.5, 1.5), 
	Vector3(7.5, 1.5, 6.5), 
	Vector3(7.5, 1.5, 11.5) 
]

var players_loaded = false
func _ready():
	
	$ResourcePreloader.add_resource("player", preload("res://player/cubio.tscn")) 
	PlayerManager.player_joined.connect(spawn_player)
	PlayerManager.player_left.connect(delete_player)

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

	for i in PlayerManager.player_data.keys():
		spawn_player(i)
		
	for ai in PlayerManager.ai_players:
		spawn_ai(ai + PlayerManager.player_data.size())
	
	players_loaded = true
			
	add_starting_position()
	add_unbreakables()
	add_breakables()
	


func add_starting_position():
	# define the starting places
	var positions = [
		# left column
		Vector3(1, 1, 0), Vector3(0, 1, 1), Vector3(1, 1, 1),
		Vector3(2, 1, 1), Vector3(1, 1, 2),

		Vector3(1, 1, 5), Vector3(0, 1, 6), Vector3(1, 1, 6),
		Vector3(2, 1, 6), Vector3(1, 1, 7),

		Vector3(1, 1, 10), Vector3(0, 1, 11), Vector3(1, 1, 11),
		Vector3(2, 1, 11), Vector3(1, 1, 12),

		# right column
		Vector3(14, 1, 0), Vector3(13, 1, 1), Vector3(14, 1, 1),
		Vector3(15, 1, 1), Vector3(14, 1, 2),

		Vector3(14, 1, 5), Vector3(13, 1, 6), Vector3(14, 1, 6),
		Vector3(15, 1, 6), Vector3(14, 1, 7),

		Vector3(14, 1, 10), Vector3(13, 1, 11), Vector3(14, 1, 11),
		Vector3(15, 1, 11), Vector3(14, 1, 12),

		# center column
		Vector3(7, 1, 0), Vector3(6, 1, 1), Vector3(7, 1, 1),
		Vector3(8, 1, 1), Vector3(7, 1, 2),

		Vector3(7, 1, 5), Vector3(6, 1, 6), Vector3(7, 1, 6),
		Vector3(8, 1, 6), Vector3(7, 1, 7),

		Vector3(7, 1, 10), Vector3(6, 1, 11), Vector3(7, 1, 11),
		Vector3(8, 1, 11), Vector3(7, 1, 12)
	]
	
	# set the cell items for each player
	for pos in positions:
		gridmap.set_cell_item(pos, 3)	
		
func spawn_player(player_num: int):
	#var player_scene = load("res://demo/demo_player.tscn")
	#var player_node = player_scene.instantiate()
	
	if (players_loaded):
		player_num = player_num + PlayerManager.ai_players
	# create the player node	
	var player_scene = $ResourcePreloader.get_resource("player") #player_scene.instantiate() as CharacterBody3D
	var player_node = player_scene.instantiate()
	player_node.set_script(player_script)
	player_node.global_position = player_start_location[player_num]
	player_node.color = player_colors[player_num]
	player_node.scale = Vector3(.7, .7, .7) 
	player_node.rotation = Vector3.UP
	player_node.connect("drop_bomb", _on_player_drop_bomb)
	
	
	player_node.leave.connect(on_player_leave)
	player_nodes[player_num] = player_node
	
	# let the player know which device controls it
	var device = PlayerManager.get_player_device(player_num)
	player_node.init(player_num, device)
	
	# add the player to the tree
	add_child(player_node)
	

func spawn_ai(ai_num : int):
	# create the player node	
	var player_scene = $ResourcePreloader.get_resource("player") #player_scene.instantiate() as CharacterBody3D
	var player_node = player_scene.instantiate()
	player_node.set_script(ai_script)
	player_node.global_position = player_start_location[ai_num]
	player_node.color = player_colors[ai_num]
	player_node.scale = Vector3(.7, .7, .7) 
	player_node.rotation = Vector3.UP
	player_nodes[ai_num] = player_node
	
	# add the player to the tree
	add_child(player_node)
	
func delete_player(player: int):
	player_nodes[player].queue_free()
	player_nodes.erase(player)

func on_player_leave(player: int):
	# just let the player manager know this player is leaving
	# this will, through the player manager's "player_left" signal,
	# indirectly call delete_player because it's connected in this file's _ready()
	PlayerManager.leave(player)
				
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
			
func _on_bomb_explode(bomb_location : Vector3, bomb_size : int, bomb_color :Color):
	var e = explosion.instantiate()
	e.explosion_size = bomb_size
	e.explosion_color = bomb_color
	e.global_position = bomb_location + Vector3.UP * .5
	var tween = create_tween()
	add_child(e)
	tween.tween_property($Camera3D, "fov", 77, 0.04).from_current()
	tween.tween_property($Camera3D, "fov", 74, 0.04).from_current()
	tween.tween_property($Camera3D, "fov", 75, 0.04).from_current()
	
func _on_breakable_removed(location : Vector3):
	var s = smoke.instantiate()
	s.global_position = location
	add_child(s)
	
	await get_tree().create_timer(1.5).timeout
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
		instance.color = player.color
		instance.connect("on_explode", _on_bomb_explode)
		instance.global_position = Vector3(hovered_point.x + 0.5, hovered_point.y, hovered_point.z + 0.5)

		player.add_collision_exception_with(instance)
		add_child(instance)
