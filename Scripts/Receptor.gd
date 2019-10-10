extends AnimationTree

var transitions = []
var nodes = []

var collider
var position
var normal
var travel

signal travel_starting
signal process


func _stimulate(_name, _collider, _position, _normal, _travel):
	
	var playback = get('parameters/playback')
	var current = playback.get_current_node()
	
	emit_signal('travel_starting', _collider, _position, _normal, _travel)
	
	playback.travel(_name)


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


func _process(delta):
	
	emit_signal('process')