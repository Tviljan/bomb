extends CSGBox3D


signal on_after_explode
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func remove():
	on_after_explode.emit(global_position)
	queue_free()
