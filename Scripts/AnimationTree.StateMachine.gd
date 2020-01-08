extends AnimationNodeStateMachine

const camera_rig_track_path = '../../Perspective'

var node_name
var parent
var parameters
var transitions = []
var nodes = []

var current_node = get_start_node()

signal state_starting
signal travel_starting


func _filter_anim_events(is_action, filter_all=false):
	
	var playback = parent.get(parameters + 'playback')
	
	
	for node in nodes:
		
		var is_playing = get_node(current_node) == node
		
		if node is AnimationNodeAnimation:
		
			var animation = parent.get_node('AnimationPlayer').get_animation(node.animation)

			for track in animation.get_track_count():
				
				var is_function_call = animation.track_get_type(track) == 2
				var is_camera_and_overriden = is_action and camera_rig_track_path in str(animation.track_get_path(track))
				
				animation.track_set_enabled(track, false if ((is_function_call and not is_playing) or filter_all) else true)# or is_camera_and_overriden else true)
		
		
		if node is AnimationNodeBlendSpace1D or node is AnimationNodeBlendSpace2D or node is AnimationNodeStateMachine:
			
			node._filter_anim_events(is_action, filter_all) if is_playing else node._filter_anim_events(is_action, true)


func _unfilter_anim_events():
	
	for node in nodes:
		
		if node is AnimationNodeAnimation:
			
			var animation = parent.get_node('AnimationPlayer').get_animation(node.animation)
			
			for track in node.animation.get_track_count():
				node.animation.track_set_enabled(track, true)
		
		if node is AnimationNodeBlendSpace1D or node is AnimationNodeBlendSpace2D:
			
			node._unfilter_anim_events()


func _ready(_parent, _parameters, _node_name):
	
	parent = _parent
	parameters = _parameters
	node_name = _node_name
	
	parent.connect('on_process', self, '_process')
	
	
	if get_transition_count() == 0:
		
		var start_name = get_start_node()
		var start = get_node(start_name)
		
		if start.has_method('_ready'):
		
			start._ready(self, parameters + start_name, parameters)
#			if start is AnimationNodeStateMachine or start is AnimationNodeBlendSpace1D or start is AnimationNodeBlendSpace2D:
#				start._ready(self, parameters, parameters + start_name)
#			else:
#				start._ready(self, parameters, start_name)
		
		nodes.append(start)
		
		return
	
	
	var anim_names = []
	
	for idx in range(get_transition_count()):
		
		var transition = get_transition(idx)
		var from_name = get_transition_from(idx)
		var to_name = get_transition_to(idx)
		var from = get_node(from_name)
		var to = get_node(to_name)
		
		
		if not from_name in anim_names:
			
			if from.has_method('_ready'):
				
				from._ready(parent, parameters + from_name, parameters)
				
#				if from is AnimationNodeStateMachine or from is AnimationNodeBlendSpace1D or from is AnimationNodeBlendSpace2D:
#					from._ready(self, parameters, parameters + from_name)
#				else:
#					from._ready(self, parameters, from_name)
			
			anim_names.append(from_name)
			nodes.append(from)
		
		
		if from.has_method('_ready'):
			from.transitions.append(transition)
		
		if transition.has_method('_ready'):
			transition._ready(self, parameters, from, to)


func _process(delta):
	
	var playback = parent.get(parameters + 'playback')
	
	if current_node != playback.get_current_node():
		emit_signal('state_starting', playback.get_current_node())
	
	current_node = playback.get_current_node()