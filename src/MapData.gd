extends Node

@onready var Nav : NavigationRegion3D = $NavigationRegion3D
@onready var Grid : GridMap = $NavigationRegion3D/GridMap
@onready var breakable = preload("res://nodes/bricks/breakable.tscn")
var map_data = {}

var map_width
var map_height
var _tile_offset = Vector3(.5,0,.5)

signal on_after_block_explode

func create(map_width, map_height) -> void:
	Grid.clear()
	$NavigationRegion3D/Node.queue_free()
	
	self.map_width = map_width
	self.map_height = map_height
	
	for x in range(0,map_width):
		for z in range(0,map_height):
			Grid.set_cell_item(Vector3(x,0,z),0)
			
	#Walls
	for z in range(-1,map_height + 1):
		Grid.set_cell_item(Vector3(-1,1,z),0)
		Grid.set_cell_item(Vector3(map_width,1,z),0)
		
	for x in range(0,map_width):
		Grid.set_cell_item(Vector3(x,1,-1),0)
		Grid.set_cell_item(Vector3(x,1,map_height),0)
	
	add_starting_position()
	add_unbreakables()
	add_breakables()
	$NavigationRegion3D.bake_navigation_mesh(true)
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
		Grid.set_cell_item(pos, 3)	
		
func add_unbreakables():
	
	for h in range(0,map_height):		
		for w in range(0,map_width):
			if fmod(h, 3) == 0 and fmod(w,3) == 0:
				if Grid.get_cell_item(Vector3(w,1,h)) == -1:
					Grid.set_cell_item(Vector3(w,1,h),1)
				
func add_breakables():
	for h in range(0,map_height):		
		for w in range(0,map_width):
			if fmod(w, 2) != 0:
				continue
				
			if Grid.get_cell_item(Vector3(w,1,h)) == -1:
				var b = breakable.instantiate()
				b.global_position =Vector3(w,1.5,h) +_tile_offset
				b.connect("on_after_explode", _on_breakable_removed)
				Nav.add_child(b)
			else:
				print ("blocked add_breakables")

func _on_breakable_removed(location : Vector3):
	on_after_block_explode.emit(location)
	await get_tree().create_timer(1).timeout
	$NavigationRegion3D.bake_navigation_mesh(true)
	
