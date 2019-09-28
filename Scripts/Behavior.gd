extends AnimationTree

var nodes = []
var current_node
var blend_mode = Inf.Blend.ACTION

signal travel_starting
signal interaction_started
signal animation_changed
signal on_process


func _get_visible_interactions():
	
	var interactions = []
	
	for node in nodes:
		if node._is_visible() and tree_root.can_travel(node.name):
			interactions.append(node.name)
	
	return interactions


func _has_interaction(_name):
	
	return false#has_node(_name)


func _start_interaction(_name):
	
	var playback = get('parameters/playback')
	var current = playback.get_current_node()
	
	if not tree_root.has_node(_name):
		return
	
	
	emit_signal('travel_starting', tree_root.get_node(_name))
	
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
			
			from._ready(self, from_name)
			
			anim_names.append(from_name)
			nodes.append(from)
		
		from.transitions.append(transition)
		
		if transition.has_method('_ready'):
			transition._ready(self, from, to)


func _set_skeleton():
	
	var skeleton = $'../Model'.get_child(0)
	$AnimationPlayer.root_node = $AnimationPlayer.get_path_to(skeleton)


func _ready():
	
	if not has_meta('unique'):
		Inf._make_unique(self)
		return
	
	_init_transitions()
	_set_skeleton()
	
	active = true


func _process(delta):
	
	var playback = get('parameters/playback')
	
	if current_node != playback.get_current_node():
		emit_signal('animation_changed', playback.get_current_node())
	
	current_node = playback.get_current_node()
	
	emit_signal('on_process')