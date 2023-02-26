extends CharacterBody3D

@onready var shape_cast = $ShapeCast3D
#@onready var camera = $Target/Camera3D
@onready var start_position = position
@export var current_bomb_size := 1
@export var bomb_time_seconds := 1.5
@export var bombs := 1

@export var move_right_action := "move_right"
@export var move_left_action := "move_left"
@export var move_forward_action := "move_forward"
@export var move_back_action := "move_back"
@export var drop_bomb_action := "jump"
@export var color = Color.WHITE
var moveSpeed := 100.0
signal drop_bomb

signal leave
var player: int
var input

var dir : Vector3 = Vector3.ZERO
var angle : float
# call this function when spawning this player to set up the input object based on the device
func init(player_num: int, device: int):
	player = player_num
	# Get the MeshInstance3D node
	var newMaterial = StandardMaterial3D.new()
	newMaterial.albedo_color = color
	$Face.material_override = newMaterial
	$Body.material_override = newMaterial

	# in my project, I got the device integer by accessing the singleton autoload PlayerManager
	# but for simplicity, it's not an autoload in this demo.
	# but I recommend making it a singleton so you can access the player data from anywhere.
	# that would look like the following line, instead of the device function parameter above.
	# var device = PlayerManager.get_player_device(player)
	input = DeviceInput.new(device)
	
	#$Player.text = "%s" % player_num


var active_bombs = 0
func _physics_process(delta:float) -> void:
	rotation_degrees = Vector3.UP
	
	if (not on_ground()):
		velocity.y  = -1
		velocity = velocity * delta * moveSpeed
		move_and_slide()
		pass
		
	# Input
	if input.is_action_pressed(move_right_action):
		velocity.x += 1
	if input.is_action_pressed(move_left_action):
		velocity.x -= 1
	if input.is_action_pressed(move_forward_action):
		velocity.z -= 1
	if input.is_action_pressed(move_back_action):
		velocity.z += 1
		
	velocity = velocity * delta * moveSpeed
	
	# move the character
	move_and_slide()
	if input.is_action_just_released(drop_bomb_action) and active_bombs < bombs:
		active_bombs += 1
		print ("drop bomb %s out of %s ", active_bombs, bombs)
		get_tree().create_timer(bomb_time_seconds).timeout.connect(bomb_explode_timer)
		drop_bomb.emit(self)
		
	#rotate
	var rotation = velocity.normalized()
#	print (global_position)
	look_at(rotation * 90)
	
func bomb_explode_timer():
	active_bombs -= 1
	
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

func _on_area_3d_area_entered(area):
	print ("area entered")
	if area.is_in_group("pickable"):
		print ("pickable")
		var root_node = get_tree().get_root()
		var owner_node = area.get_owner()
#		var owner_scene = owner_node.get_tree().get_current_scene()
#		print("The owner node of the Area3D node is: ", owner_node)
#		print("The owner node's scene is: ", owner_scene)
#		var g = area.get_node("parent")
#		var b = area.get_node("parent")
#		var d = area.get_tree()
		owner_node.picked(self)
		owner_node.remove() # Replace with function body.
