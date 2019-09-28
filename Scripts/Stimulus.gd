extends AnimationTree

var transitions = []
var nodes = []

signal on_physics_process
signal on_process


func _init_transitions():
	
	var anim_names = []
	
	for idx in range(tree_root.get_transition_count()):
		
		var transition = tree_root.get_transition(idx)
		var anim_name = tree_root.get_transition_to(idx)
		var animation = tree_root.get_node(anim_name)
		
		if not anim_name in anim_names:
			
			if animation.has_method('_ready'):
				animation._ready(self)
				nodes.append(animation)
				anim_names.append(anim_name)
		
		if transition.has_method('_ready'):
			transition._ready(self)


func _ready():
	
	if not has_meta('unique'):
		Inf._make_unique(self)
		return
	
	_init_transitions()
	
	active = true


func _physics_process(delta):
	
	emit_signal('on_physics_process', delta)


func _process(delta):
	
	emit_signal('on_process')