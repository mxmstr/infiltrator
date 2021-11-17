extends "res://Scripts/AnimationLoader.gd"

export(String) var state

var new_state = ''


func _ready():
	
	if tree.is_empty():
		return
	
	tree_node.connect('action', self, '_on_action')


func _play(_animation, _down=null, _up=null):
	
	var result
	
	if _up and _down:
		result = tree_node._play(new_state, _animation, attributes[_animation], _up, _down)
	else:
		result = tree_node._play(new_state, _animation, attributes[_animation])
	
	if random:
		_randomize_animation()
	
	return result


func _on_action(_state, data): 
	
	new_state = _state
	
	if new_state == state:
		_play(animation_list[0])
