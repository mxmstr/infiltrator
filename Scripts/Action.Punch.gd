extends "res://Scripts/Action.gd"

export(String) var schema_idle
export(String) var schema_kick

var animation_list_idle = []
var animation_list_kick = []


func _on_action(_state, data):
	
	if _state == 'PunchIdle':
		
		_play(_state, animation_list_idle[0])
	
	if _state == 'Punch':
		
		_play(_state, animation_list[0])
		_randomize_animation()
	
	elif _state == 'Kick':
		
		_play(_state, animation_list_kick[0])


func _ready():
	
	if tree.is_empty():
		return
	
	animation_list_idle = _load_animations(schema_idle)
	animation_list_kick = _load_animations(schema_kick)
