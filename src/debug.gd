extends Node3D


var check_length = 2
var imported_int = 1
var collider : PhysicsDirectSpaceState3D

func _ready():
	collider = get_world_3d().direct_space_state

func _is_hit(from:Vector3, to:Vector3) -> Dictionary:
	
	var q = PhysicsRayQueryParameters3D.create(from, to, 5)
	q.hit_back_faces = false
	q.hit_from_inside = false
	return collider.intersect_ray(q)
	
func _process(delta):
	
	var from = transform.origin
	
	var h =_is_hit(from + Vector3(0.5, .5, 0), from + Vector3(check_length * imported_int, .5, 0))
	if h:
	# Handle collision in the right direction
		print ("collision in the right direction")

	if _is_hit(from+ Vector3(-0.5, .5, 0), Vector3(-check_length * imported_int, .5, 0)):
	# Handle collision in the left direction
		print ("collision in the left direction")

	if _is_hit(from + Vector3(0, .5, .5), Vector3(0, .5, check_length * imported_int)):
	# Handle collision in the forward direction
		print ("collision in the forward direction")

	if _is_hit(from + Vector3(0, .5, -.5), Vector3(0, .5, -check_length * imported_int)):
	# Handle collision in the back direction
		print ("collision in the back direction")

func _on_collision_shape_3d_child_entered_tree(node):
	print ("caught one") # Repl


func _on_timer_timeout():
	queue_free()
