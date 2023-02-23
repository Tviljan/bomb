extends CSGTorus3D
# Called when the node enters the scene tree for the first time.
func _ready(): # Replace with function body.
	add_to_group("pickable")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.rotate(Vector3.BACK, 5 * delta)

func remove():
	queue_free()

func picked(player:CharacterBody3D):
	player.current_bomb_size += 1
