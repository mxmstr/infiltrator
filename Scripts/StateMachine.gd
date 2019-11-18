extends AnimationTree

var current_node
var nodes = []
var transitions = []

signal state_starting
signal travel_starting

signal on_physics_process
signal on_process


func _start_state(_name, data={}):
	
	var playback = get('parameters/playback')
	var current = playback.get_current_node()
	
	if not tree_root.has_node(_name):
		return
	
	
	emit_signal('travel_starting', _name, tree_root.get_node(_name))
	
	playback.travel(_name)


func _init_transitions():
	
	var anim_names = []
	
	for idx in range(tree_root.get_transition_count()):
		
		var transition = tree_root.get_transition(idx)
		var from_name = tree_root.get_transition_from(idx)
		var to_name = tree_root.get_transition_to(idx)
		var from = tree_root.get_node(from_name)
		var to = tree_root.get_node(to_name)
		
		if not from_name in anim_names:
			
			if from.has_method('_ready'):
				from._ready(self, from_name)
			
			anim_names.append(from_name)
			nodes.append(from)
		
		if from.has_method('_ready'):
			from.transitions.append(transition)
		
		if transition.has_method('_ready'):
			transition._ready(self, from, to)


func _ready():
	
	if not has_meta('unique'):
		Inf._make_unique(self)
		return
	
	_init_transitions()
	
	active = true


func _physics_process(delta):
	
	emit_signal('on_physics_process', delta)


func _process(delta):
	
	var playback = get('parameters/playback')
	
	if current_node != playback.get_current_node():
		emit_signal('state_starting', playback.get_current_node())
	
	current_node = playback.get_current_node()
	
	emit_signal('on_process', delta)