extends StaticBody3D

signal on_explode

@export var explosion_size : int = 3
# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.connect("timeout", _explode)

func _explode():
	on_explode.emit(self.global_position, explosion_size)
	queue_free()
	
func remove():
	$Timer.stop()
	await get_tree().create_timer(0.1).timeout
	_explode()


func _on_collision_shape_3d_child_exiting_tree(node):
	print ("exit") # Replace with function body.


func _on_area_3d_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	if (body):
		body.remove_collision_exception_with(self)
