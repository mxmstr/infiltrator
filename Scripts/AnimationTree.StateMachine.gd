tool
extends AnimationNodeStateMachine

const camera_rig_track_path = '../../Perspective'

export var chain = false

var node_name
var owner
var parent
var parameters
var connections = []
var advance = false

signal state_starting
signal travel_starting


func _on_state_starting(new_name):
	
	if node_name == new_name:
		advance = chain


func _filter_anim_events(is_action, filter_all=false):
	
	var playback = owner.get(parameters + 'playback')
	var current_node = playback.get_current_node()
	var children = get_child_nodes()
	
	if current_node == '':
		return

	for child_name in children:
		
		var child = children[child_name]
		var is_playing = get_node(playback.get_current_node()) == child
		
		if child is AnimationNodeAnimation:
		
			var animation = owner.get_node('AnimationPlayer').get_animation(child.animation)

			for track in animation.get_track_count():
				
				var is_function_call = animation.track_get_type(track) == 2
				var is_camera_and_overriden = is_action and camera_rig_track_path in str(animation.track_get_path(track))
				
				animation.track_set_enabled(track, false if (is_function_call and (not is_playing or filter_all)) else true)# or is_camera_and_overriden else true)
		
		
		if child is AnimationNodeStateMachine or \
			child is AnimationNodeBlendTree or \
			child is AnimationNodeBlendSpace1D or \
			child is AnimationNodeBlendSpace2D:
			
			child._filter_anim_events(is_action, filter_all) if is_playing else child._filter_anim_events(is_action, true)


func _unfilter_anim_events():
	
	var playback = owner.get(parameters + 'playback')
	var current_node = playback.get_current_node()
	var children = get_child_nodes()
	
	if current_node == '':
		return
	
	for child_name in children:
		
		var child = children[child_name]
		
		if child is AnimationNodeAnimation:
			
			var animation = owner.get_node('AnimationPlayer').get_animation(child.animation)
			
			for track in child.animation.get_track_count():
				child.animation.track_set_enabled(track, true)
		
		if child is AnimationNodeStateMachine or \
			child is AnimationNodeBlendTree or \
			child is AnimationNodeBlendSpace1D or \
			child is AnimationNodeBlendSpace2D:
			
			child._unfilter_anim_events()


func _travel(_name):
	
	var playback = owner.get(parameters + 'playback')
	var current = playback.get_current_node()
	
	if not has_node(_name):
		return
	
	
	owner.emit_signal('travel_starting', _name, get_node(_name))
	
	playback.travel(_name)
	
	owner.advance(0.01)
	owner.emit_signal('on_process', 0)


func _editor_ready(_owner, _parent, _parameters, _name):
	
	var children = get_child_nodes()

	for child_name in children:
		
		var child = children[child_name]
		
		if child.has_method('_editor_ready'):

			if child is AnimationNodeStateMachine or \
				child is AnimationNodeBlendTree or \
				child is AnimationNodeBlendSpace1D or \
				child is AnimationNodeBlendSpace2D:
				child._editor_ready(_owner, self, _parameters + child_name + '/', child_name)
			else:
				child._editor_ready(_owner, self, _parameters, child_name)


func _ready(_owner, _parent, _parameters, _node_name):
	
	owner = _owner
	parent = _parent
	parameters = _parameters
	node_name = _node_name
	
	if parent != null and owner.get(parent.parameters + 'playback') != null:
		owner.get(parent.parameters + 'playback').connect('state_starting', self, '_on_state_starting')
	
	owner.connect('on_process', self, '_process')


	var children = get_child_nodes()

	for child_name in children:
		
		var child = children[child_name]
		
		if child.has_method('_ready'):

			if child is AnimationNodeStateMachine or \
				child is AnimationNodeBlendTree or \
				child is AnimationNodeBlendSpace1D or \
				child is AnimationNodeBlendSpace2D:
				child._ready(owner, self, parameters + child_name + '/', child_name)
			else:
				child._ready(owner, self, parameters, child_name)
	
	
	var anim_names = []

	for idx in range(get_transition_count()):

		var transition = get_transition(idx)
		var from_name = get_transition_from(idx)
		var to_name = get_transition_to(idx)
		var from = get_node(from_name)
		var to = get_node(to_name)

		if from.has_method('_ready'):
			from.connections.append(transition)

		if transition.has_method('_ready'):
			transition._ready(owner, self, parameters, from, to)


func _process(delta):
	
	if advance:
		owner.advance(0.01)
	
	advance = false
