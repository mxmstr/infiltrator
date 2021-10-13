extends "res://Scripts/AnimationLoader.gd"


func _ready():
	
	if tree.is_empty():
		return
	
	tree_node.connect('action', self, '_on_action')


func _set_animation(_animation, pitch=0):
	
	if attributes[_animation].has('layer'):
		tree_node._set_layer(Meta.BlendLayer[attributes[_animation].layer])
	
	
	var scale = 1.0
	var clip_start = 0
	var clip_end = 0
	
	if attributes[_animation].has('speed'):
		scale = attributes[_animation].speed
	
	if attributes[_animation].has('clip_start'):
		clip_start = attributes[_animation].clip_start
	
	if attributes[_animation].has('clip_end'):
		clip_end = attributes[_animation].clip_end
	
	if pitch == 0:
		tree_node._set_animation(_animation, scale, clip_start, clip_end)
	elif pitch == 1:
		tree_node._set_animation_up(_animation, scale, clip_start, clip_end)
	elif pitch == -1:
		tree_node._set_animation_down(_animation, scale, clip_start, clip_end)


func _start_action():
	
	tree_node._set_oneshot_active(true)


func _on_action(state, data): pass