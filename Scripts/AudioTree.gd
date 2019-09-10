extends AnimationTree

signal animation_changed


func _play_schema(_name):
	
	var playback = get('parameters/playback')
	var current = playback.get_current_node()
	
	emit_signal('animation_changed')
	
	print(_name)
	playback.travel(_name)


func _init_transitions():
	
	var anim_names = []
	
	for idx in range(tree_root.get_transition_count()):
		
		var transition = tree_root.get_transition(idx)
		var anim_name = tree_root.get_transition_from(idx)
		var animation = tree_root.get_node(anim_name)
		
		if not anim_name in anim_names:
			
			if animation.has_method('init'):
				animation.init(self)
				animation.transitions.append(transition)
			
			anim_names.append(anim_name)
			
		else:
			if animation.has_method('init'):
				animation.transitions.append(transition)
		
		if transition.has_method('init'):
			transition.init(self)


func _ready():
	
	_init_transitions()
	
	active = true


func _process(delta):
	
	$AudioStreamPlayer3D.global_transform.origin = get_parent().global_transform.origin