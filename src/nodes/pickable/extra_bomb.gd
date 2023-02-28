extends Node3D
@onready var circle = $CSGTorus3D
@onready var plus : CSGCombiner3D = $CSGCombiner3D
# Called when the node enters the scene tree for the first time.

func _ready(): # Replace with function body.
	var tween = create_tween()
	self.scale = Vector3.ZERO
	tween.tween_property(self, "scale", Vector3.ONE, 1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	circle.rotate(Vector3.BACK, 4 * delta)
	plus.rotate(Vector3.BACK, .5 * delta)

func remove():
	queue_free()

func picked(player:CharacterBody3D):
	player.bombs += 1
