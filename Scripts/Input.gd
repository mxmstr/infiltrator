extends AnimationTree

signal on_process


func _init_transitions():
	
	var anim_names = []
	
	for idx in range(tree_root.get_transition_count()):
		
		var transition = tree_root.get_transition(idx)
		var anim_name = tree_root.get_transition_to(idx)
		var animation = tree_root.get_node(anim_name)
		
		if not anim_name in anim_names:
			anim_names.append(anim_name)
		
		if transition.has_method('init'):
			transition.init(self, anim_name)


func _ready():
	
	tree_root = tree_root.duplicate(true)
	
	_init_transitions()
	
	active = true


func _process(delta):
	
	emit_signal('on_process')