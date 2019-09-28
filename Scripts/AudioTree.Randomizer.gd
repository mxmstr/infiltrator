extends AnimationNodeAnimation

var parent
var anim_name
var transitions = []
var last = -1


func init(_parent, _anim_name):
	
	parent = _parent
	anim_name = _anim_name
	
	parent.connect('animation_changed', self, '_on_animation_changed')


func _on_animation_changed(new_anim):
	
	if anim_name == new_anim:
		
		var enabled_idx = last
		
		while enabled_idx == last:
			enabled_idx = randi() % len(transitions)
		
		for idx in range(len(transitions)):
			transitions[idx].disabled = idx != enabled_idx
		
		last = enabled_idx