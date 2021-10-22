extends "res://Scripts/Action.gd"

export(String) var schema_idle
export(String) var schema_kick

var animation_list_idle = []
var animation_list_kick = []


func _on_action(state, data):
	
	._on_action(state, data)
	
	if state == 'PunchIdle':
		
		_play(animation_list_idle[0])
	
	if state == 'Punch':
		
		_play(animation_list[0])
		_randomize_animation()
	
	elif state == 'Kick':
		
		_play(animation_list_kick[0])


func _ready():
	
	if tree.is_empty():
		return
	
	animation_list_idle = _load_animations(schema_idle)
	animation_list_kick = _load_animations(schema_kick)