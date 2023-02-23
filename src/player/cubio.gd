extends CharacterBody3D

@onready var shape_cast = $ShapeCast3D
#@onready var camera = $Target/Camera3D
@onready var start_position = position
@export var current_bomb_size := 1

var moveSpeed := 100.0
signal drop_bomb

var dir : Vector3 = Vector3.ZERO
var angle : float
func _physics_process(delta:float) -> void:
	if (not on_ground()):
		velocity.y  = -1
		velocity = velocity * delta * moveSpeed
		move_and_slide()
		pass
		
	# Input
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_forward"):
		velocity.z -= 1
	if Input.is_action_pressed("move_back"):
		velocity.z += 1
		
	velocity = velocity * delta * moveSpeed
	
	# move the character
	move_and_slide()
	if Input.is_action_just_released("jump"):
		drop_bomb.emit(self)
		
	#rotate
	var rotation = velocity.normalized()
#	print (global_position)
	look_at(rotation * 90)

func remove():
	print ("I died")
	queue_free()
	
func explode(explosion : StaticBody3D):
	print ("I was caught in explosion")
	
func lerp_angle(from, to, weight):
	return from + short_angle_dist(from, to) * weight

func short_angle_dist(from, to):
	var max_angle = PI * 2
	var difference = fmod(to - from, max_angle)
	return fmod(2 * difference, max_angle) - difference
	
# Test if there is a body below the player.
func on_ground():
	if shape_cast.is_colliding():
		return true

func _on_tcube_body_entered(body):
	if body == self:
		get_node(^"WinText").show()

func _on_area_3d_area_entered(area):
	print ("area entered")
	if area.is_in_group("pickable"):
		print ("pickable")
		area.get_parent().picked(self)
		area.get_parent().remove() # Replace with function body.
