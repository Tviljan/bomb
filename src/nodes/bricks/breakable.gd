extends CSGBox3D


signal on_after_explode
var removed = false
# Called when the node enters the scene tree for the first time.
func _ready():
	var tween = create_tween()
	var f =randf_range(0.2,0.5)
	tween.tween_property(self, "scale", Vector3.ONE, f).from(Vector3.ZERO)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func remove():
	if !removed:
		removed = true
		on_after_explode.emit(global_position)
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector3.ZERO, 1)
		tween.tween_callback(queue_free)
