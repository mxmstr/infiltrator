extends AnimationNodeAnimation

export(String) var path

var name
var parent
var transitions = []

signal on_enter


func _on_animation_changed(new_name):
	
	if name == new_name:
		
		emit_signal('on_enter')


func init(_name, _parent):
	
	name = _name
	parent = _parent
	
	parent.connect('animation_changed', self, '_on_animation_changed')