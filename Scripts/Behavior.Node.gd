extends AnimationNodeAnimation

export(Inf.Priority) var priority
export(Inf.Visibility) var type
export(Inf.Blend) var blend_mode
export var speed = 1.0
export var distance = 0.0

var name
var parent
var transitions = []

signal on_enter


func _is_visible():
	
	return type != Inf.Visibility.INVISIBLE


func _on_animation_changed(new_name):
	
	if name == new_name:
		
		parent.get_node('AnimationPlayer').playback_speed = speed
		parent.blend_mode = blend_mode
		
		emit_signal('on_enter')


func _ready(_parent, _name):
	
	parent = _parent
	name = _name
	
	parent.connect('animation_changed', self, '_on_animation_changed')