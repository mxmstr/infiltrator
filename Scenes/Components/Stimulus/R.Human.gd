extends AnimationTree


func _ready():
	
	var start_name = tree_root.get_start_node()
	var start = tree_root.get_node(start_name)
	
	print('asdf ', start.get_transition_count())
	
	if Engine.editor_hint: return
	
	if not has_meta('unique'):
		Inf._make_unique(self)
		return
	
	
	
#	if start.has_method('_ready'):
#		start._ready(self, null, 'parameters/' + start_name + '/', start_name)
	
	print(start.get_transition_count())
	
	active = true