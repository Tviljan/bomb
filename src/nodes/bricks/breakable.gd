extends CSGBox3D


signal on_after_explode
# Called when the node enters the scene tree for the first time.
func _ready():
	var tween = create_tween()
	self.scale = Vector3.ZERO
	var f =randf_range(0.2,0.5)
	tween.tween_property(self, "scale", Vector3.ONE, f)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func remove():
	on_after_explode.emit(global_position)
	queue_free()
