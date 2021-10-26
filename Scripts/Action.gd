extends "res://Scripts/AnimationLoader.gd"

export(String) var state


func _ready():
	
	if tree.is_empty():
		return
	
	tree_node.connect('action', self, '_on_action')


func _play(_animation, _down=null, _up=null):
	
	if _up and _down:
		tree_node._play(state, _animation, attributes[_animation], _up, _down)
	else:
		tree_node._play(state, _animation, attributes[_animation])


func _on_action(_state, data): 
	
	if _state == state:
		_play(animation_list[0])