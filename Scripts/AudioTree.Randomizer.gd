extends AnimationNodeAnimation

var parent
var transitions = []


func init(_parent):
	
	parent = _parent
	
	parent.connect('animation_changed', self, '_on_animation_changed')


func _on_animation_changed():
	
	var enabled_idx = randi() % len(transitions)
	
	for idx in range(len(transitions)):
		transitions[idx].disabled = idx != enabled_idx