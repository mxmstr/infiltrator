extends AnimationTree



func _play_schema(_name):
	
	var playback = get('parameters/playback')
	var current = playback.get_current_node()
	
	playback.travel(_name)


func _init_transitions():
	
	var anim_names = []
	
	for idx in range(tree_root.get_transition_count()):
		
		var transition = tree_root.get_transition(idx)
		var anim_name = tree_root.get_transition_to(idx)
		
		if not anim_name in anim_names:
			anim_names.append(anim_name)
		
		if transition.has_method('init'):
			transition.init(self)


func _ready():
	
	_init_transitions()
	
	active = true


func _process(delta):
	
	pass#print(get('parameters/playback').get_current_node())
	
	#$AudioStreamPlayer3D.global_transform.origin = get_parent().global_transform.origin