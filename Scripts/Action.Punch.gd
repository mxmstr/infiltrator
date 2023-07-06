extends "res://Scripts/Action.gd"

@export var schema_idle: String

var animation_list_idle = []


func _on_action(_state, data):
	
	if _state == 'PunchIdle':
		
		_play(_state, animation_list_idle[0])
	
	if _state == 'Punch':
		
		_play(_state, animation_list[0])
		_randomize_animation()


func _ready():
	
	await get_tree().idle_frame
	
	animation_list_idle = _load_animations(schema_idle)
