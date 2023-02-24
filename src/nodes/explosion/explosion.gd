extends Node3D
# This script extends the Node3D class and implements a custom explosion effect. 
# It uses the PhysicsDirectSpaceState3D class to perform a raycast in the given direction to check if there's an obstacle that blocks the explosion. 
# If the raycast hits an obstacle, the explosion is stopped at the hit point. If not, the explosion continues until the specified length. 
#
# The explosion is represented by MeshInstance3D objects with a BoxMesh and a custom material. 
# The resulting explosion can be visualized in the scene as a series of boxes.

var collider : PhysicsDirectSpaceState3D
var from : Vector3 = Vector3.ZERO
var hit_location = []
var hit_origin = []
var hit_box = []

var hit_location_left = 0
var hit_location_right = 1
var hit_location_forward = 2
var hit_location_back = 3

@onready var explosion_material = preload("res://nodes/explosion/explosion_material.tres")
@export var explosion_size :int = 2

##Function for setting the cast length
func _init(cast_length:int = 2):
	explosion_size = cast_length	


func _ready():

	collider = get_world_3d().direct_space_state
	from = self.global_position
	hit_location = [explosion_size,explosion_size,explosion_size,explosion_size]
	hit_box = [Vector3.ONE,Vector3.ONE,Vector3.ONE,Vector3.ONE]
	hit_origin = [Vector3.ONE,Vector3.ONE,Vector3.ONE,Vector3.ONE]
	check_explosion_size()
	draw_explosion()

func _process(delta):
	check_objects_in_explosion()
	
##Function for checking the explosion size to each direction
func check_explosion_size():
	hit_location[hit_location_left] = get_explosion_end(Vector3.LEFT)
	hit_location[hit_location_right] = get_explosion_end(Vector3.RIGHT) 
	hit_location[hit_location_forward] = get_explosion_end(Vector3.FORWARD)
	hit_location[hit_location_back] = get_explosion_end(Vector3.BACK)

	
##Function for drawing explosion to each direction
func draw_explosion()->void:
	draw_explosion_cube(hit_location[hit_location_left])
	draw_explosion_cube(hit_location[hit_location_right]) 
	draw_explosion_cube(hit_location[hit_location_forward])
	draw_explosion_cube(hit_location[hit_location_back])
	
##Function for drawing the explosion mesh to a given collision target
func draw_explosion_cube(collision: Vector3)-> void:
	var mesh_instance = MeshInstance3D.new()
	var cube = BoxMesh.new()
	var cube_size = Vector3.ONE
	var direction = collision - from
	var multiplier = 1
	var origin = Vector3.ZERO
	var cube_width = .5
	var cube_height = .5
	var key = -1
	var addition = 0
	if direction.x > 0:
		direction.x += addition
		cube_size = Vector3(direction.x, cube_height, cube_width)
#		origin = Vector3(round(direction.x /2 - .001), 0, 0)
		origin = Vector3(direction.x /2, 0, 0)
		key = hit_location_right
	elif direction.x < 0:
		direction.x -= addition
		cube_size = Vector3(-direction.x , cube_height, cube_width)
#		origin = Vector3(round(direction.x /2 + .001), 0, 0)
		origin = Vector3(direction.x /2, 0, 0)
		key = hit_location_left
	elif direction.z > 0:
		
		direction.z += addition
		cube_size = Vector3(cube_width, cube_height, direction.z)
#		origin = Vector3(0, 0, round(direction.z/2 - .001))  
		
		origin = Vector3(0, 0, direction.z/2)  
		key = hit_location_forward
	elif direction.z < 0:	
		direction.z -= addition
		cube_size = Vector3(cube_width, cube_height, -direction.z)
#		origin = Vector3(0, 0, round(direction.z /2 + .001) ) 
		
		origin = Vector3(0, 0, direction.z /2) 
		key = hit_location_back
	
	# Set the material of the explosion box
	mesh_instance.material_override = explosion_material
	cube.size = cube_size
	mesh_instance.mesh = cube
	hit_box[key] = cube_size
	hit_origin[key] = origin
	mesh_instance.global_transform.origin = origin
	add_child(mesh_instance)

##Check if explosion is blocked
func is_hit(from:Vector3, to:Vector3) -> Dictionary:
	var q = PhysicsRayQueryParameters3D.create(from, to,  1 << 4)
	return collider.intersect_ray(q)
	
## Function for performing a shapecast using a box shape to remove everyhing inside explosion
func destroy_cast(origin : Vector3, box_size: Vector3, direction : Vector3):
	# Create a new box shape object
	var cube = BoxShape3D.new()
	
	# Set the size of the box shape to the given size	
	var cube_padding = -.6
	var explosion_addition = .5
	
	# Print the size of the collider cube
	if direction.x > 0:
		cube.size = Vector3(box_size.x + explosion_addition, 1, box_size.z +cube_padding)
	elif direction.x < 0:
		cube.size = Vector3(box_size.x  + explosion_addition, 1, box_size.z +cube_padding)
	elif direction.z > 0:	
		cube.size = Vector3(box_size.x + cube_padding, 1, box_size.z + explosion_addition)
	elif direction.z < 0:		
		cube.size = Vector3(box_size.x +cube_padding, 1, box_size.z + explosion_addition)
	# Create a new physics shape query object
	var query = PhysicsShapeQueryParameters3D.new()
	
	# Set the shape of the query object to the cube shape
	
	query.set_shape(cube)

	# Set the transformation of the query object to the global transform translated by the given box size

	query.transform = global_transform.translated_local(origin)
	
	# Set the collision mask of the query object to only detect objects with a certain layer
	query.collision_mask = 1 << 5
			
	var g = query.transform.translated_local(origin)
	Debugger.draw_line_3d(origin, origin + Vector3.UP * 3, Color(0,0,0))
	Debugger.draw_transformed_cube(g, Color(0,1,0))
	# Perform the shapecast, getting up to 32 results
	
	var result = collider.intersect_shape(query, 32)
	
	# If there are any results from the shapecast
	if not result.is_empty():
		# Iterate over each object in the result
		for object in result:
			# Draw a line from the object's global position to its global position plus Vector3.UP
			# The color of the line is set to a shade of pink (Color(1,0,1))
			Debugger.draw_box(object["collider"].global_position, Vector3(1,2,1))
			
			Debugger.draw_line_3d(object["collider"].global_position, object["collider"].global_position + Vector3.UP * 5, Color(1,0,1))
			var o = object["collider"].get_owner()
			if o:
		
				
				o.remove()
			else:
				object["collider"].remove()
						


##Function for calculating the explosion size to given direction using explosion_size variable
func get_explosion_end(direction : Vector3) -> Vector3:
	
	var to = Vector3.ZERO
	var addition = Vector3.ZERO
	var from_addition = 0#.5
#	if direction.x > 0:
#		to = Vector3(from.x + from_addition, from.y, from.z) + direction * explosion_size
#	elif direction.x < 0:
#		to = Vector3(from.x - from_addition, from.y, from.z) + direction * explosion_size
#	elif direction.z > 0:
#		to = Vector3(from.x, from.y, from.z + from_addition) + direction * explosion_size
#	elif direction.z < 0:	
	to = Vector3(from.x, from.y, from.z - from_addition) + direction * explosion_size 
	
	var hit_dic = is_hit(from, to)
	
	if hit_dic: 
		var hit_location = hit_dic["position"]
		return hit_location + addition
	else:
		return to

##Function for checking if objects are in explosion
func check_objects_in_explosion():
	Debugger.draw_line_3d(Vector3(from.x,0,from.z), Vector3(from.x,0,from.z), Color(0,1,1))
	Debugger.draw_line_3d(Vector3(hit_location[hit_location_left].x,0,hit_location[hit_location_left].z), Vector3(hit_location[hit_location_left].x,0,hit_location[hit_location_left].z) + Vector3.UP*3, Color(0,1,1))
	Debugger.draw_line_3d(Vector3(hit_location[hit_location_right].x,0,hit_location[hit_location_right].z), Vector3(hit_location[hit_location_right].x,0,hit_location[hit_location_right].z) + Vector3.UP*3, Color(0,1,1))
	Debugger.draw_line_3d(Vector3(hit_location[hit_location_forward].x,0,hit_location[hit_location_forward].z), Vector3(hit_location[hit_location_forward].x,0,hit_location[hit_location_forward].z) + Vector3.UP*3, Color(0,1,1))
	Debugger.draw_line_3d(Vector3(hit_location[hit_location_back].x,0,hit_location[hit_location_back].z), Vector3(hit_location[hit_location_back].x,0,hit_location[hit_location_back].z) + Vector3.UP*3, Color(0,1,1))
	destroy_cast(hit_origin[hit_location_left],hit_box[hit_location_left], Vector3.LEFT)
	destroy_cast(hit_origin[hit_location_right],hit_box[hit_location_right], Vector3.RIGHT)
	destroy_cast(hit_origin[hit_location_forward], hit_box[hit_location_forward], Vector3.FORWARD)
	destroy_cast(hit_origin[hit_location_back],hit_box[hit_location_back], Vector3.BACK)
	
	
func _on_timer_timeout():
	queue_free()
