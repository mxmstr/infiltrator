extends "res://Scripts/AnimationLoader.gd"

export(String) var state

var data = {}
var new_data = {}


func _ready():
	
	yield(get_tree(), 'idle_frame')
	
	if tree.is_empty():
		return
	
	tree_node.connect('action', self, '_on_action')


func _play(_state, _animation, _attributes_prefix='', _down=null, _up=null):
	
	var attributes_name = _attributes_prefix + _animation
	var attributes_cloned = attributes[attributes_name].duplicate()
	
	if new_data.has('override'):
		attributes_cloned.override = true
	
	var result
	
	if _up and _down:
		result = tree_node._play(_state, _animation, attributes_cloned, _up, _down)
	else:
		result = tree_node._play(_state, _animation, attributes_cloned)
	
	if random:
		_randomize_animation()
	
	return result


func _state_start(): pass


func _on_action(_state, _data):
	
	new_data = _data
	
	if _state == state and _play(state, animation_list[0]):
		
		data = new_data
		_state_start()
