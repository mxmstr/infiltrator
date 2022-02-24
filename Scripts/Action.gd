extends "res://Scripts/AnimationLoader.gd"

export(String) var state

var data


func _ready():
	
	if tree.is_empty():
		return
	
	tree_node.connect('action', self, '_on_action')


func _play(_state, _animation, _attributes_prefix='', _down=null, _up=null):
	
	var attributes_name = _attributes_prefix + _animation
	var result
	
	if _up and _down:
		result = tree_node._play(_state, _animation, attributes[attributes_name].duplicate(), _up, _down)
	else:
		result = tree_node._play(_state, _animation, attributes[attributes_name].duplicate())
	
	if random:
		_randomize_animation()
	
	return result


func _state_start(): pass


func _on_action(_state, _data):
	
	if _state == state and _play(state, animation_list[0]):
		
		data = _data
		_state_start()
