extends Node3D
@onready var circle = $CSGTorus3D
@onready var star1 = $Star1
@onready var star2 = $Star2

# Called when the node enters the scene tree for the first time.
func _ready(): # Replace with function body.
	var tween = create_tween().set_loops()
	self.scale = Vector3.ZERO
	tween.tween_property(self, "scale", Vector3.ONE, 1)
	tween.tween_property(self, "scale", Vector3(.8,.8,.8), .4)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	circle.rotate(Vector3.BACK, 4 * delta)
	star1.rotate(Vector3.UP, .5 * delta)
	star2.rotate(Vector3.UP, .5 * delta)

func remove():
	queue_free()

func picked(player:CharacterBody3D):
	player.current_bomb_size += 1
