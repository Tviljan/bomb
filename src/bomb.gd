extends StaticBody3D

signal on_explode

@export var explosion_size : int = 2
# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.connect("timeout", _explode)

func _explode():
	on_explode.emit(self.global_position, explosion_size)
	queue_free()
	
