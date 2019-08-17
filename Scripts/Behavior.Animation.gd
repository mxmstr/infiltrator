extends AnimationNode

enum visibility {
	INVISIBLE,
	PHYSICAL, 
	REMOTE
}

export(visibility) var type
export var speed = 1.0
export var distance = 0.0

var name


func _on_animation_changed(anim_name):
	
	if get_caption() == anim_name:
		pass


func init(_name, parent):
	
	name = _name
	
	parent.connect('animation_changed', self, '_on_animation_changed')