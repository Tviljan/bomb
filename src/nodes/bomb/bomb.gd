extends StaticBody3D

signal on_explode

@export var explosion_size : int = 3
@export var bomb_timer : float = 2.0
@export var color = Color.WHITE

# Called when the node enters the scene tree for the first time.
func _ready():
	var newMaterial = StandardMaterial3D.new()
	newMaterial.albedo_color = color
	$Sphere.material_override = newMaterial
	$Timer.wait_time = bomb_timer
	$Timer.connect("timeout", _explode)
	var tween = create_tween()
	var scale = Vector3(.9,.9,.9)
	var f =randf_range(0.2,0.5)
	tween.tween_property(self, "scale", scale, .5)
	tween.tween_property(self, "scale", Vector3.ONE, .5)
	tween.set_loops(10)

func _explode():
	print ("create boom size of ", explosion_size)
	on_explode.emit(self.global_position, explosion_size)
	queue_free()
	
func remove():
	$Timer.stop()
	await get_tree().create_timer(0.1).timeout
	_explode()


func _on_collision_shape_3d_child_exiting_tree(node):
	print ("exit") # Replace with function body.


func _on_area_3d_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	if (body is CharacterBody3D):
		body.remove_collision_exception_with(self)
