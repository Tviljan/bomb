extends Node3D
# This script extends the Node3D class and implements a custom explosion effect. 
# It uses the PhysicsDirectSpaceState3D class to perform a raycast in the given direction to check if there's an obstacle that blocks the explosion. 
# If the raycast hits an obstacle, the explosion is stopped at the hit point. If not, the explosion continues until the specified length. 
#
# The explosion is represented by MeshInstance3D objects with a BoxMesh and a custom material. 
# The resulting explosion can be visualized in the scene as a series of boxes.

# In the _ready function, the PhysicsDirectSpaceState3D is obtained and the explosion is initiated with the draw_explosion function. 
# The hit_test function performs the raycast and returns the size of the explosion box at the end of the explosion. 
# The draw_explosion function draws the explosion in four directions (left, right, forward, and backward), filling the hit_location hit_locationay with the size of the explosion boxes in each direction. 
# The add_explosion function creates a new MeshInstance3D object with a BoxMesh, sets its size and position, and adds it as a child of the script object. 
# The shapecast function performs a shapecast to check for collision with other objects and removes the objects if there's a collision.

var collider : PhysicsDirectSpaceState3D
var from : Vector3 = Vector3.ZERO
var hit_location = []
var hit_origin = []
var hit_box = []
@onready var explosion_material = preload("res://new_standard_material_3d.tres")
@export var explosion_size :int = 2

func _init(cast_length:int = 2):
	explosion_size = cast_length	
	
#Check if explosion is blocked
func is_hit(from:Vector3, to:Vector3) -> Dictionary:
	var q = PhysicsRayQueryParameters3D.create(from, to,  1 << 4)
	return collider.intersect_ray(q)
	
# Function for performing a shapecast using a box shape
func destroy_cast(origin : Vector3, box_size: Vector3, direction : Vector3):
	# Create a new box shape object
	var cube = BoxShape3D.new()
	
	# Set the size of the box shape to the given size
	
	var cube_padding = -.6
	var explosion_addition = .75
	# Print the size of the collider cube
	print("Collider cube size:", box_size)
	if direction.x > 0:
		print("destroy_cast to RIGHT")	
		cube.size = Vector3(box_size.x + explosion_addition, 1, box_size.z +cube_padding)

	elif direction.x < 0:
		print("destroy_cast to LEFT")		
		cube.size = Vector3(box_size.x  + explosion_addition, 1, box_size.z +cube_padding)

	elif direction.z > 0:
		print("destroy_cast to FORWARD")		
		cube.size = Vector3(box_size.x + cube_padding, 1, box_size.z + explosion_addition)

	elif direction.z < 0:
		print("destroy_cast to BACK")			
		cube.size = Vector3(box_size.x +cube_padding, 1, box_size.z + explosion_addition)
	# Create a new physics shape query object
	var query = PhysicsShapeQueryParameters3D.new()
#	Debugger.draw_axes(query.transform)
	# Set the shape of the query object to the cube shape
	
	query.set_shape(cube)

	# Set the transformation of the query object to the global transform translated by the given box size

	query.transform = global_transform.translated_local(origin)
	
	# Set the collision mask of the query object to only detect objects with a certain layer
	query.collision_mask = 1 << 5
	
	# Set the margin of the query object to .9
#	query.margin = 0.5
	
#	print("shapecast origin", -origin)			
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
			
			# Uncomment the following line to remove the object from the scene
			object["collider"].remove()

func _ready():

	collider = get_world_3d().direct_space_state
	from = self.global_position
	hit_location = [explosion_size,explosion_size,explosion_size,explosion_size]
	hit_box = [Vector3.ONE,Vector3.ONE,Vector3.ONE,Vector3.ONE]
	hit_origin = [Vector3.ONE,Vector3.ONE,Vector3.ONE,Vector3.ONE]
	check_explosion_size()
	draw_explosion()
	
func draw_explosion()->void:
	draw_explosion_cube(hit_location[hit_location_left])
	draw_explosion_cube(hit_location[hit_location_right]) 
	draw_explosion_cube(hit_location[hit_location_forward])
	draw_explosion_cube(hit_location[hit_location_back])

func draw_explosion_cube(collision: Vector3)-> void:
	var mesh_instance = MeshInstance3D.new()
	var cube = BoxMesh.new()
	var cube_size = Vector3.ONE
	var direction = collision - from
	var multiplier = 1
	var origin = Vector3.ZERO
	
	var key = -1
	
	if direction.x > 0:
		print("add_explosion to RIGHT")	
		cube_size = Vector3(direction.x , 1, 1)
		origin = Vector3(round(direction.x /2 - .001), 0, 0)
		key = hit_location_right
	elif direction.x < 0:
		print("add_explosion to LEFT")		
		cube_size = Vector3(-direction.x , 1, 1)
		origin = Vector3(round(direction.x /2 + .001), 0, 0)
		key = hit_location_left
	elif direction.z > 0:
		print("add_explosion to FORWARD")		
		cube_size = Vector3(1, 1, direction.z)
		origin = Vector3(0, 0, round(direction.z/2 - .001))  
		key = hit_location_forward
	elif direction.z < 0:
		print("add_explosion to BACK")			
		cube_size = Vector3(1, 1, -direction.z)
		origin = Vector3(0, 0, round(direction.z /2 + .001) ) 
		key = hit_location_back
	# Calculate the size and position of the explosion box based on the direction of the explosion
	
	# Set the material of the explosion box
	mesh_instance.material_override = explosion_material
	cube.size = cube_size
	mesh_instance.mesh = cube
	hit_box[key] = cube_size
	hit_origin[key] = origin
	print("cube_size, ", cube_size)
	print ("origin ",origin)
	mesh_instance.global_transform.origin = origin
	add_child(mesh_instance)
	
func get_explosion_end(direction : Vector3) -> Vector3:
	
	var to = Vector3.ZERO
	var addition = Vector3.ZERO
	if direction.x > 0:
		print("RIGHT")	
		to = Vector3(from.x + .5, from.y, from.z) + direction * explosion_size
#		addition.x += 1
	elif direction.x < 0:
		print("LEFT")		
		to = Vector3(from.x - .5, from.y, from.z) + direction * explosion_size
#		addition.x -= 1
	elif direction.z > 0:
		print("FORWARD")	
		to = Vector3(from.x, from.y, from.z + .5) + direction * explosion_size
#		addition.z += 1
	elif direction.z < 0:
		print("BACK")		
		to = Vector3(from.x, from.y, from.z - .5) + direction * explosion_size
#		addition.z -= .5
	
	var hit_dic = is_hit(from, to)
	
	if hit_dic: 

#		Debugger.draw_line_3d(from, from + Vector3.UP, Color(1,0,0))
#		Debugger.draw_line_3d(from + Vector3.UP, from + Vector3.UP +hit_dic["position"]+ direction, Color(1,0,0))
		var hit_location = hit_dic["position"]
		print ("hit_test from ",from)
		print ("hit_test hit_location ",hit_location)
		return hit_location + addition
#		return add_explosion(from, hit_location + direction)
	else:
		print ("hit_test from  ",from)
		print ("hit_test hit_location ",to)
		return to


var hit_location_left = 0
var hit_location_right = 1
var hit_location_forward = 2
var hit_location_back = 3

#Draws explosion until explosion size or blocking object is reached
#Fills hit_location with boxes
func check_explosion_size():
	hit_location[hit_location_left] = get_explosion_end(Vector3.LEFT)
	hit_location[hit_location_right] = get_explosion_end(Vector3.RIGHT) 
	hit_location[hit_location_forward] = get_explosion_end(Vector3.FORWARD)
	hit_location[hit_location_back] = get_explosion_end(Vector3.BACK)

		
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
	
func _process(delta):
	check_objects_in_explosion()
	
func _ray_hit(ray:RayCast3D)-> bool:
	return ray.is_colliding()
	
	
func _on_timer_timeout():
	queue_free()
