extends Node3D

var collider : PhysicsDirectSpaceState3D
var from : Vector3 = Vector3.ZERO

@export var explosion_size :int = 2

func _init(cast_length:int = 2):
	explosion_size = cast_length	
	
func _ready():
	
	
		
	collider = get_world_3d().direct_space_state
	from = self.global_position
	
	if _is_hit(from, from + Vector3(explosion_size, .5, 0)): 
	# Handle collision in the right direction
		print ("collision in the right direction")
	else:
		var mesh_instance = MeshInstance3D.new()
		mesh_instance.mesh = BoxMesh.new()
		mesh_instance.scale = Vector3.ONE + Vector3.RIGHT * explosion_size
		add_child(mesh_instance)

	if _is_hit(from, from + Vector3(-explosion_size, .5, 0)): # ):
	# Handle collision in the left direction
		print ("collision in the left direction")
	else:
		var mesh_instance = MeshInstance3D.new()
		mesh_instance.mesh = BoxMesh.new()
		mesh_instance.scale = Vector3.ONE + Vector3.LEFT * explosion_size
		add_child(mesh_instance)
		
	if _is_hit(from , from +Vector3(0, .5, explosion_size)):
	# Handle collision in the forward direction
		print ("collision in the forward direction")
	else:
		var mesh_instance = MeshInstance3D.new()
		mesh_instance.mesh = BoxMesh.new()
		mesh_instance.scale = Vector3.ONE + Vector3.FORWARD * explosion_size
		add_child(mesh_instance)
		
	if _is_hit(from , from + Vector3(0, .5, -explosion_size)):
	# Handle collision in the back direction
		print ("collision in the back direction")
	else:
		var mesh_instance = MeshInstance3D.new()
		mesh_instance.mesh = BoxMesh.new()
		mesh_instance.scale = Vector3.ONE + Vector3.BACK * explosion_size
		add_child(mesh_instance)

		
func _ray_hit(ray:RayCast3D)-> bool:
	return ray.is_colliding()
	
func _is_hit(from:Vector3, to:Vector3) -> Dictionary:
	
	var q = PhysicsRayQueryParameters3D.create(from, to, 0b00000000000000010000)

	return collider.intersect_ray(q)
	

func _on_collision_shape_3d_child_entered_tree(node):
	print ("caught one") # Repl


func _on_timer_timeout():
	queue_free()
