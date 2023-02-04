extends MeshInstance3D

var check_length = 2
var imported_int = 1
var collider : PhysicsDirectSpaceState3D
var from : Vector3 = Vector3.ZERO
func _ready():
	collider = get_world_3d().direct_space_state
	from = self.global_position
	
func _ray_hit(ray:RayCast3D)-> bool:
	return ray.is_colliding()
	
func _is_hit(from:Vector3, to:Vector3) -> Dictionary:
	
	var q = PhysicsRayQueryParameters3D.create(from, to, 0b00000000000000010000)
	
#	q.hit_back_faces = false
#	q.hit_from_inside = false
#	q.collide_with_areas = false
	#q.collide_with_bodies = false
#	q.collision_mask = 0b00000000000000010000
	var co = collider.intersect_ray(q)
	if co:
		
		print ("hit")
	return co
	
func _process(delta):
#
	if _is_hit(from, from + Vector3(check_length * imported_int, .5, 0)): 
	# Handle collision in the right direction
		print ("collision in the right direction")

	if _is_hit(from, from + Vector3(-check_length * imported_int, .5, 0)): # ):
	# Handle collision in the left direction
		print ("collision in the left direction")

	if _is_hit(from , from +Vector3(0, .5, check_length * imported_int)):
	# Handle collision in the forward direction
		print ("collision in the forward direction")

	if _is_hit(from , from + Vector3(0, .5, -check_length * imported_int)):
	# Handle collision in the back direction
		print ("collision in the back direction")

func _on_collision_shape_3d_child_entered_tree(node):
	print ("caught one") # Repl


func _on_timer_timeout():
	queue_free()
