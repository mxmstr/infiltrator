extends AnimationNodeStateMachine

const camera_rig_track_path = '../../Perspective'

export(String) var statemachine

export var chain = false

var node_name
var owner
var parent
var parameters
var connections = []
var nodes = []
var advance = false

signal state_starting
signal travel_starting


func _on_state_starting(new_name):
	
	if node_name == new_name:
		advance = chain


func _filter_anim_events(is_action, filter_all=false):
	
	var playback = owner.get(parameters + 'playback')
	
	for node in nodes:
		
		var is_playing = get_node(playback.get_current_node()) == node
		
		if node is AnimationNodeAnimation:
		
			var animation = owner.get_node('AnimationPlayer').get_animation(node.animation)

			for track in animation.get_track_count():
				
				var is_function_call = animation.track_get_type(track) == 2
				var is_camera_and_overriden = is_action and camera_rig_track_path in str(animation.track_get_path(track))
				
				animation.track_set_enabled(track, false if (is_function_call and (not is_playing or filter_all)) else true)# or is_camera_and_overriden else true)
		
		
		if node is AnimationNodeStateMachine or node is AnimationNodeBlendSpace1D or node is AnimationNodeBlendSpace2D:
			
			node._filter_anim_events(is_action, filter_all) if is_playing else node._filter_anim_events(is_action, true)


func _unfilter_anim_events():
	
	for node in nodes:
		
		if node is AnimationNodeAnimation:
			
			var animation = owner.get_node('AnimationPlayer').get_animation(node.animation)
			
			for track in node.animation.get_track_count():
				node.animation.track_set_enabled(track, true)
		
		if node is AnimationNodeBlendSpace1D or node is AnimationNodeBlendSpace2D:
			
			node._unfilter_anim_events()


func _travel(_name):
	
	var playback = owner.get(parameters + 'playback')
	var current = playback.get_current_node()
	
	if not has_node(_name):
		return
	
	
	owner.emit_signal('travel_starting', _name, get_node(_name))
	
	playback.travel(_name)
	
	
	owner.advance(0.01)
	owner.emit_signal('on_process', 0)


func _ready(_owner, _parent, _parameters, _node_name):
	
	owner = _owner
	parent = _parent
	parameters = _parameters
	node_name = _node_name
	
	if parent != null and owner.get(parent.parameters + 'playback') != null:
		owner.get(parent.parameters + 'playback').connect('state_starting', self, '_on_state_starting')
	
	owner.connect('on_process', self, '_process')
	
	
	if get_transition_count() == 0:

		var start_name = get_start_node()
		var start = get_node(start_name)

		if start.has_method('_ready'):

			if start is AnimationNodeStateMachine or start is AnimationNodeBlendSpace1D or start is AnimationNodeBlendSpace2D:
				start._ready(owner, self, parameters + start_name + '/', start_name)
			else:
				start._ready(owner, self, parameters, start_name)

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

				if from is AnimationNodeStateMachine or from is AnimationNodeBlendSpace1D or from is AnimationNodeBlendSpace2D:
					from._ready(owner, self, parameters + from_name + '/', from_name)
				else:
					from._ready(owner, self, parameters, from_name)

			anim_names.append(from_name)
			nodes.append(from)


		if from.has_method('_ready'):
			from.connections.append(transition)

		if transition.has_method('_ready'):
			transition._ready(owner, self, parameters, from, to)


func _process(delta):
	
	if advance:
		owner.advance(0.01)
	
	advance = false
