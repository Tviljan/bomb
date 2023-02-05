extends CSGTorus3D

# Called when the node enters the scene tree for the first time.
func _ready(): # Replace with function body.
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.rotate(Vector3.BACK, 5 * delta)

func remove():
	queue_free()
