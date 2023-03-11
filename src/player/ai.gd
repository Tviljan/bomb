extends CharacterBody3D

@onready var shape_cast = $ShapeCast3D
#@onready var camera = $Target/Camera3D
@onready var start_position = position
@export var current_bomb_size := 1
@export var bomb_time_seconds := 1.5
@export var bombs := 1
@export var leela = preload("res://player/Leela.gltf")
@export var leela_texture = preload("res://player/arrayMesh.tres")
@export var move_right_action := "move_right"
@export var move_left_action := "move_left"
@export var move_forward_action := "move_forward"
@export var move_back_action := "move_back"
@export var drop_bomb_action := "jump"
@export var color = Color.WHITE
var moveSpeed := 80.0

signal drop_bomb
signal died
signal leave

var player_number: int
var input

var dir : Vector3 = Vector3.ZERO
var angle : float
# call this function when spawning this player to set up the input object based on the device
func init(player_num: int, device: int):
	player_number = player_num
#	$Leela/AnimationPlayer.play("Hello")
#	# Get the MeshInstance3D node
	var material = StandardMaterial3D.new()

	material.albedo_color = color
	$Marker.material = material

#	$Leela/RobotArmature/Skeleton3D/Leela2/surface_material_override/0 = material
#	$Leela/RobotArmature/Skeleton3D/Leela2
	

	# in my project, I got the device integer by accessing the singleton autoload PlayerManager
	# but for simplicity, it's not an autoload in this demo.
	# but I recommend making it a singleton so you can access the player data from anywhere.
	# that would look like the following line, instead of the device function parameter above.
	# var device = PlayerManager.get_player_device(player)
	input = DeviceInput.new(device)
	
	#$Player.text = "%s" % player_num


var active_bombs = 0
func _physics_process(delta:float) -> void:
#	rotation_degrees = Vector3.UP
	
	if (not on_ground()):
		velocity.y  = -1
		velocity = velocity * delta * moveSpeed
		print ("not on ground")
		move_and_slide()
		pass
	
	$Leela/AnimationPlayer.play("Dance")
	
		
	#rotate
	#self.rotate(Vector3(0, 1, 0), rotation.x * 45)
#	print ("rot, ", rotation)
#	var v = velocity
#	if rotation == Vector3.ZERO:
#		print("looking ", velocity)
#		last_target = transform.origin - velocity
	look_at(transform.origin - velocity,Vector3.UP)
#	else:
#		look_at(last_target,Vector3.UP)
		
var last_target
func bomb_explode_timer():
	active_bombs -= 1
	
func remove():
	print ("I died")
	died.emit(player_number)
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
