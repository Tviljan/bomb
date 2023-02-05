extends CSGBox3D

# Called when the node enters the scene tree for the first time.
func _ready():
	print ("breakable ready")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func remove():
	print ("remove called")
	queue_free()
