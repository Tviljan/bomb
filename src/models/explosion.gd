extends Node3D

var collider : PhysicsDirectSpaceState3D
var from : Vector3 = Vector3.ZERO
var arr = []

@onready var explosion_material = preload("res://new_standard_material_3d.tres")
@export var explosion_size :int = 2

func _init(cast_length:int = 2):
	explosion_size = cast_length	

	
#Check if explosion is blocked
func _is_hit(from:Vector3, to:Vector3) -> Dictionary:
	var q = PhysicsRayQueryParameters3D.create(from, to,  1 << 4)
	return collider.intersect_ray(q)
	
func add_explosion(directionVector : Vector3, size : int) -> Vector3:
	
	var mesh_instance = MeshInstance3D.new()
	var cube = BoxMesh.new()
	
	if directionVector.x < 0 or directionVector.z < 0:
		cube.size = Vector3.ONE + (-1 * directionVector * size)
	else:
		cube.size = Vector3.ONE + directionVector * size
	mesh_instance.material_override = explosion_material
		
	mesh_instance.global_position = mesh_instance.global_position + (directionVector * size / 2) 
	mesh_instance.mesh = cube
	add_child(mesh_instance)
	return mesh_instance.global_position
	
func shapecast(direction_vector : Vector3, size : int):
	var cube = BoxShape3D.new()
	var cube_size = direction_vector * size
	
	#let's make the cube a bit smaller 
	if direction_vector.x < 0 or direction_vector.z < 0:
		cube_size *= -0.8
	else:
		cube_size *= 0.8
		
	cube.size = cube_size
	
	var query = PhysicsShapeQueryParameters3D.new()
	
	query.set_shape(cube)
	query.transform = global_transform.translated(direction_vector)
	query.collision_mask = 1 << 5
	query.margin = 1.1
	
	var result = collider.intersect_shape(query, 32)
	if not result.is_empty():
		for object in result:
			object["collider"].remove() # removes the object from the scene
			

func _ready():

	collider = get_world_3d().direct_space_state
	from = self.global_position
	arr = [explosion_size,explosion_size,explosion_size,explosion_size]
	explode()
	
#explosions until hit blocking object or end of length
func explode():

	var hit_right = _is_hit(from, from + Vector3(explosion_size, .5, 0))
	if hit_right: 
	# Handle collision in the right direction
		print ("collision in the right direction")
		var hit_location = (from - hit_right["position"])
		var rounded = int(round(hit_location.x))
		
		add_explosion(Vector3.RIGHT, -rounded)
		arr[0] = -rounded
	else:
		add_explosion(Vector3.RIGHT, explosion_size)

	var hit_left = _is_hit(from, from + Vector3(-explosion_size, .5, 0))
	if hit_left:
	# Handle collision in the left direction
		print ("collision in the left direction")
		var hit_location = (from - hit_left["position"])
		var rounded = int(round(hit_location.x))
		add_explosion(Vector3.LEFT, rounded)
		
		arr[1] = rounded
	else:
		add_explosion(Vector3.LEFT, explosion_size)

	var hit_forward= _is_hit(from , from +Vector3(0, .5, -explosion_size))
	if hit_forward:	
	# Handle collision in the forward direction
		print ("collision in the forward direction") 
		var hit_location = (from - hit_forward["position"])
		var rounded = int(round(hit_location.z))
		add_explosion(Vector3.FORWARD, -rounded)
		arr[2] = -rounded
	else:
		add_explosion(Vector3.FORWARD, explosion_size)

	var hit_back = _is_hit(from , from + Vector3(0, .5, explosion_size))
	if hit_back:	
	# Handle collision in the back direction
		print ("collision in the back direction")
		var hit_location = (from - hit_back["position"])
		var rounded = int(round(hit_location.z))
		add_explosion(Vector3.BACK, rounded)
		arr[3] = rounded
	else:
		add_explosion(Vector3.BACK, explosion_size)
		
func check_objects_in_explosion():
	shapecast(Vector3.RIGHT, arr[0])
	shapecast(Vector3.LEFT,  arr[1])
	shapecast(Vector3.FORWARD, arr[2])
	shapecast(Vector3.BACK, arr[3])
	
func _process(delta):
	check_objects_in_explosion()
		
func _ray_hit(ray:RayCast3D)-> bool:
	return ray.is_colliding()
	
	
func _on_timer_timeout():
	queue_free()
