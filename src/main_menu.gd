extends Node2D

const LEVEL_PATH = "res://level.tscn"

var player_count = 0
var ai_count = 0
@onready var PlayerCountLabel = $MarginContainer/VBoxContainer/VBoxContainer/VBoxContainer/Player_count_label
@onready var AiCountLaber = $MarginContainer/VBoxContainer/VBoxContainer/VBoxContainer/Ai_count_label
@onready var Helper = $MarginContainer/VBoxContainer/key_helper_label

# Called when the node enters the scene tree for the first time.
func _ready():
	PlayerManager.player_joined.connect(spawn_player)
	PlayerManager.player_left.connect(delete_player)
	var inputs = InputMap.action_get_events("join")
	# Create a string to display the inputs to the player
	var input_string = "Press start to join \n"
	for input in inputs:
		input_string += input.as_text() + ""
	Helper.text = input_string
	preload("res://player/cubio.tscn")

func _player_count_changed() -> void:
	
	PlayerCountLabel.text = str(player_count)
	AiCountLaber.text = str(ai_count)
	$MarginContainer/VBoxContainer/VBoxContainer/new_game_button.disabled = player_count + ai_count < 2

func spawn_player(player_num: int):
	player_count += 1
	_player_count_changed()
	
func delete_player(player: int):
	player_count -= 1
	_player_count_changed()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	PlayerManager.handle_join_input()


func _on_new_game_button_pressed():
	PlayerManager.ai_players = ai_count
	SceneManager.change_scene(LEVEL_PATH,{ "pattern": "scribbles", "pattern_leave": "squares" })
	

func _on_increase_ai_count_button_pressed():
	if (ai_count + player_count) < 9:
		ai_count+=1 
	_player_count_changed()


func _on_decrease_ai_count_button_pressed():
	if ai_count > 0:
		ai_count-=1 
	_player_count_changed()
