extends AnimationTree

signal on_physics_process
signal on_process


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
	
	
	if tree_root.has_method('_ready'):
		tree_root._ready(self, 'parameters/', '')
	
	active = true


func _physics_process(delta):
	
	emit_signal('on_physics_process', delta)


func _process(delta):
	
	if Engine.editor_hint: return
	
	emit_signal('on_process', delta)