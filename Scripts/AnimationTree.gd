extends AnimationTree

signal on_physics_process
signal on_process
signal travel_starting


func _start_state(_name, data={}):
	
	var playback = get('parameters/playback')
	var current = playback.get_current_node()
	
	if not tree_root.has_node(_name):
		return
	
	
	emit_signal('travel_starting', _name, tree_root.get_node(_name))
	
	playback.travel(_name)


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