extends AnimationNodeAnimation

export(Inf.visibility) var type
export(Inf.blend) var blend_mode
export var blocks_travel = false
export var speed = 1.0
export var distance = 0.0

var name
var parent
var transitions = []

signal on_enter


func is_visible():
	
	return type != Inf.visibility.INVISIBLE


func _on_animation_changed(new_name):
	
	if name == new_name:
		
		parent.get_node('AnimationPlayer').playback_speed = speed
		parent.blend_mode = blend_mode
		
		if blocks_travel:
			for transition in transitions:
				transition.disabled = false
		
		emit_signal('on_enter')
		
	else:
		
		if blocks_travel:
			for transition in transitions:
				transition.disabled = true


func init(_name, _parent):
	
	name = _name
	parent = _parent
	
	parent.connect('animation_changed', self, '_on_animation_changed')