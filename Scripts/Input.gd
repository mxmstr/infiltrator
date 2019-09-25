extends AnimationTree

var transitions = []

signal on_process


func _init_transitions():
	
	for idx in range(tree_root.get_transition_count()):
		
		var transition = tree_root.get_transition(idx)
		
		if transition.has_method('init'):
			transition.init(self)


func _ready():
	
	if not has_meta('unique'):
		Inf._make_unique(self)
		return
	
	_init_transitions()
	
	active = true


func _process(delta):
	
	emit_signal('on_process')