extends Node3D

var collider : PhysicsDirectSpaceState3D
var from : Vector3 = Vector3.ZERO

@onready var explosion_material = preload("res://new_standard_material_3d.tres")
@export var explosion_size :int = 2

func _init(cast_length:int = 2):
	explosion_size = cast_length	
	
func add_explosion(directionVector : Vector3, size : int) -> void:
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
	
func _ready():

	collider = get_world_3d().direct_space_state
	from = self.global_position

	var hit_right = _is_hit(from, from + Vector3(explosion_size, .5, 0))
	if hit_right: 
	# Handle collision in the right direction
		print ("collision in the right direction")
		var hit_location = (from - hit_right["position"])
		var rounded = int(round(hit_location.x))
		add_explosion(Vector3.RIGHT, -rounded)
	else:
		add_explosion(Vector3.RIGHT, explosion_size)

	var hit_left = _is_hit(from, from + Vector3(-explosion_size, .5, 0))
	if hit_left:
	# Handle collision in the left direction
		print ("collision in the left direction")
		var hit_location = (from - hit_left["position"])
		var rounded = int(round(hit_location.x))
		add_explosion(Vector3.LEFT, rounded)
	else:
#		add_explosion(Vector3.ONE + Vector3.LEFT * explosion_size)
		add_explosion(Vector3.LEFT, explosion_size)
	
	var hit_forward= _is_hit(from , from +Vector3(0, .5, -explosion_size))
	if hit_forward:	
	# Handle collision in the forward direction
		print ("collision in the forward direction") 
		var hit_location = (from - hit_forward["position"])
		var rounded = int(round(hit_location.z))
		add_explosion(Vector3.FORWARD, -rounded)
	else:
		add_explosion(Vector3.FORWARD, explosion_size)

	var hit_back = _is_hit(from , from + Vector3(0, .5, explosion_size))
	if hit_back:	
	# Handle collision in the back direction
		print ("collision in the back direction")
		var hit_location = (from - hit_back["position"])
		var rounded = int(round(hit_location.z))
		add_explosion(Vector3.BACK, rounded)
	else:
		add_explosion(Vector3.BACK, explosion_size)
		
func _ray_hit(ray:RayCast3D)-> bool:
	return ray.is_colliding()
	

func _set_exploded(from:Vector3, to:Vector3):
	pass
#	var shape_rid = PhysicsServer3D.shape_create(PhysicsServer3D.SHAPE_SPHERE)
#	var radius = 2.0
#	PhysicsServer3D.shape_set_data(shape_rid, radius)
#
#	var params = PhysicsShapeQueryParameters3D.new()
#	params.shape_rid = shape_rid
#
#	# Execute physics queries here...
#
#	# Release the shape when done with physics queries.
#	PhysicsServer3D.free_rid(shape_rid)

	
#Check if explosion is blocked
func _is_hit(from:Vector3, to:Vector3) -> Dictionary:
	var q = PhysicsRayQueryParameters3D.create(from, to, 0b00000000000000010000)
	return collider.intersect_ray(q)
	
func _on_timer_timeout():
	queue_free()
