extends AnimationTree

signal on_physics_process
signal on_process
signal travel_starting


func _start_state(_name, data={}):
	
	print([name, _name])
	
	var start_name = tree_root.get_start_node()
	var start = tree_root.get_node(start_name)
	
	if start.has_method('_travel'):
		start._travel(_name)


func _ready():
	
	var start_name = tree_root.get_start_node()
	var start = tree_root.get_node(start_name)
	
	print('asdf ', start.get_transition_count())
	
	
	if Engine.editor_hint: return
	
	if not has_meta('unique'):
		#Inf._make_unique(self)
		return
	
	
#	if start.has_method('_ready'):
#		start._ready(self, null, 'parameters/' + start_name + '/', start_name)
	
	print(start.get_transition_count())
	
	active = true


func _physics_process(delta):
	
	emit_signal('on_physics_process', delta)


func _process(delta):
	
	if Engine.editor_hint: return
	
	emit_signal('on_process', delta)