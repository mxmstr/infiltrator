extends "res://Scripts/Action.gd"


func _load_animations(_schema, _prefix=''):
	
	var _animation_list = ._load_animations(_schema, _prefix)
	
	var sorted_animation_list = []
	sorted_animation_list.resize(_animation_list.size())

	for _animation in _animation_list:
		sorted_animation_list[attributes[_animation].direction] = _animation
	
	return sorted_animation_list


func _play(_state, _animation, _attributes_prefix='', _down=null, _up=null):
	
	var result = tree_node._play_8way(_state, animation_list, attributes[animation_list[0]].duplicate())
	
	return result
