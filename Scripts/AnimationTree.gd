extends AnimationTree

signal on_physics_process
signal on_process
signal travel_starting


func _start_state(_name, data={}):
	
	var start_name = tree_root.get_start_node()
	var start = tree_root.get_node(start_name)
	
	if start.has_method('_travel'):
		start._travel(_name)


func _ready():
	
	if Engine.editor_hint: return
	
	
	if not has_meta('unique'):
		Inf._make_unique(self)
		return
	
	
	var start_name = tree_root.get_start_node()
	var start = tree_root.get_node(start_name)
	
	if start.has_method('_ready'):
		start._ready(self, 'parameters/' + start_name + '/', start_name)
	
	active = true


func _physics_process(delta):
	
	emit_signal('on_physics_process', delta)


func _process(delta):
	
	if Engine.editor_hint: return
	
	emit_signal('on_process', delta)