extends Node3D
# This script extends the Node3D class and implements a custom explosion effect. 
# It uses the PhysicsDirectSpaceState3D class to perform a raycast in the given direction to check if there's an obstacle that blocks the explosion. 
# If the raycast hits an obstacle, the explosion is stopped at the hit point. If not, the explosion continues until the specified length. 
#
# The explosion is represented by MeshInstance3D objects with a BoxMesh and a custom material. 
# The resulting explosion can be visualized in the scene as a series of boxes.

# In the _ready function, the PhysicsDirectSpaceState3D is obtained and the explosion is initiated with the draw_explosion function. 
# The hit_test function performs the raycast and returns the size of the explosion box at the end of the explosion. 
# The draw_explosion function draws the explosion in four directions (left, right, forward, and backward), filling the arr array with the size of the explosion boxes in each direction. 
# The add_explosion function creates a new MeshInstance3D object with a BoxMesh, sets its size and position, and adds it as a child of the script object. 
# The shapecast function performs a shapecast to check for collision with other objects and removes the objects if there's a collision.

var collider : PhysicsDirectSpaceState3D
var from : Vector3 = Vector3.ZERO
var arr = []

@onready var explosion_material = preload("res://new_standard_material_3d.tres")
@export var explosion_size :int = 2

func _init(cast_length:int = 2):
	explosion_size = cast_length	
	
#Check if explosion is blocked
func is_hit(from:Vector3, to:Vector3) -> Dictionary:
	var q = PhysicsRayQueryParameters3D.create(from, to,  1 << 4)
	return collider.intersect_ray(q)
	
# Create an explosion box and add it as a child to the script object
func add_explosion(from: Vector3, to: Vector3) -> Vector3:
	# Create a MeshInstance3D object to represent the explosion box
	var mesh_instance = MeshInstance3D.new()
	var cube = BoxMesh.new()
	var cube_size = Vector3.ONE
	var direction = from - to
	var multiplier = 1
	var origin = Vector3.ZERO
	
	# Calculate the size and position of the explosion box based on the direction of the explosion
	if from.x != to.x:
		cube_size = Vector3(abs(from.x - to.x) + 0.5, 1, 1)
		
		# Set the multiplier to determine the orientation of the box
		if from.x > to.x:
			multiplier = -1
		else:
			multiplier = 1
			
		# Set the origin of the box based on the size and direction of the explosion
		origin = multiplier * Vector3(abs((direction).x), 0, 0) / 2
	else:
		cube_size = Vector3(1, 1, abs(to.z - from.z) + 0.5)
		
		# Set the multiplier to determine the orientation of the box
		if from.z > to.z:
			multiplier = 1
		else:
			multiplier = -1
		
		# Set the origin of the box based on the size and direction of the explosion
		origin = multiplier * Vector3(0, 0, abs((direction).z)) / 2
	
	# Set the material of the explosion box
	mesh_instance.material_override = explosion_material
	cube.size = cube_size
	mesh_instance.mesh = cube
	
	print(cube_size)
	print(origin)
	mesh_instance.global_transform.origin = origin
	add_child(mesh_instance)
	return cube_size
	
# Function for performing a shapecast using a box shape
func shapecast(box_size: Vector3):
	# Create a new box shape object
	var cube = BoxShape3D.new()
	
	# Set the size of the box shape to the given size
	var cube_size = box_size
	cube.size = cube_size
	
	# Print the size of the collider cube
	print("Collider cube size:", cube_size)
	
	# Create a new physics shape query object
	var query = PhysicsShapeQueryParameters3D.new()
#	Debugger.draw_axes(query.transform)
	# Set the shape of the query object to the cube shape
	query.set_shape(cube)

	# Set the transformation of the query object to the global transform translated by the given box size
	query.transform = global_transform.translated(box_size)
	
	# Set the collision mask of the query object to only detect objects with a certain layer
	query.collision_mask = 1 << 5
	
	# Set the margin of the query object to .9
	query.margin = .9
	
	# Perform the shapecast, getting up to 32 results
	var result = collider.intersect_shape(query, 32)
	
	# If there are any results from the shapecast
	if not result.is_empty():
		# Iterate over each object in the result
		for object in result:
			# Draw a line from the object's global position to its global position plus Vector3.UP
			# The color of the line is set to a shade of pink (Color(1,0,1))
			Debugger.draw_line_3d(object["collider"].global_position, object["collider"].global_position + Vector3.UP, Color(1,0,1))
			
			# Uncomment the following line to remove the object from the scene
			# object["collider"].remove()

func _ready():

	collider = get_world_3d().direct_space_state
	from = self.global_position
	arr = [explosion_size,explosion_size,explosion_size,explosion_size]
	draw_explosion()
	
#explosions until hit blocking object or end of length
#returns box_size
func hit_test(direction : Vector3) -> Vector3:
	var hit_dic = is_hit(from, from + direction * explosion_size)
	
	if hit_dic: 

#		Debugger.draw_line_3d(from, from + Vector3.UP, Color(1,0,0))
#		Debugger.draw_line_3d(from + Vector3.UP, from + Vector3.UP +hit_dic["position"]+ direction, Color(1,0,0))
		var hit_location = hit_dic["position"] + direction
#		Debugger.draw_ray_3d(hit_location, Vector3.UP, 2, Color(1,0,0))
		return add_explosion(from, hit_location)
	else:
		return add_explosion(from, from + direction * explosion_size)


var arr_left = 0
var arr_right = 1
var arr_forward = 2
var arr_back = 3

#Draws explosion until explosion size or blocking object is reached
#Fills arr with boxes
func draw_explosion():

	arr[arr_left] = hit_test(Vector3.RIGHT)
	arr[arr_right] = hit_test(Vector3.LEFT)
	arr[arr_forward] = hit_test(Vector3.FORWARD)
	arr[arr_back] = hit_test(Vector3.BACK)
		
func check_objects_in_explosion():
	shapecast(arr[arr_right])
	shapecast(arr[arr_left])
	shapecast(arr[arr_forward])
	shapecast(arr[arr_back])
	
func _process(delta):
	check_objects_in_explosion()
		
func _ray_hit(ray:RayCast3D)-> bool:
	return ray.is_colliding()
	
	
func _on_timer_timeout():
	queue_free()
