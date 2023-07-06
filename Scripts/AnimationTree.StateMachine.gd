extends AnimationNodeStateMachine

const camera_rig_track_path = '../../Perspective'

@export var statemachine: String
@export var chain = false

var node_name
var owner
var parent
var parameters
var connections = []
var advance = false

var children = get_children()
var animation_nodes = []
var statemachine_nodes = []
var animation_player

signal state_starting
signal travel_starting


func _on_state_starting(new_name):
	
	if node_name == new_name:
#		if owner.name == 'Behavior' and owner.owner.name == 'Infiltrator':
#			prints('meep ',new_name)
		
		advance = chain


func _filter_anim_events(is_action, filter_all=false):
	
	var playback = owner.get(parameters + 'playback')
	
	if not playback.get_current_node():
		return
	
	var current_node = get_node(playback.get_current_node())
	

	for animation_node in animation_nodes:

		var is_playing = get_node(animation_node) == current_node
		
		if not is_playing or filter_all:
			children[animation_node].call_methods = false  
		else:
			children[animation_node].call_methods = true
	
	
	for statemachine_node in statemachine_nodes:

		var is_playing = get_node(statemachine_node) == current_node
		
		if is_playing:
			children[statemachine_node]._filter_anim_events(is_action, filter_all)
		else:
			children[statemachine_node]._filter_anim_events(is_action, true)


func _unfilter_anim_events():
	
	for animation_node in animation_nodes:
		
		children[animation_node].call_methods = true


	for statemachine_node in statemachine_nodes:
		
		children[statemachine_node]._unfilter_anim_events()


func _travel(_name):
	
#	if owner.name == 'Behavior' and owner.owner.name == 'Infiltrator':
#		prints(OS.get_system_time_msecs(), _name)
#
	var playback = owner.get(parameters + 'playback')
	var current = playback.get_current_node()
	
	if not has_node(_name):
		return
	
	
	owner.emit_signal('travel_starting', _name, get_node(_name))
	
	playback.travel(_name)
	
	if not playback.is_playing():
		prints('Not playing', owner.owner.name)
	
#	owner.advance(0.01)
#	owner.emit_signal('on_process', 0)


func _start(_name):
	
	var playback = owner.get(parameters + 'playback')
	var current = playback.get_current_node()
	
	if not has_node(_name):
		return
	
	
	owner.emit_signal('travel_starting', _name, get_node(_name))
	
#	prints('starting', owner.owner.name, _name, owner.active)
	
	playback.start(_name)
	
#	owner.advance(0.01)
#	owner.emit_signal('on_process', 0)


func _editor_ready(_owner, _parent, _parameters, _name):
	
	var children = get_children()

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


func __ready(_owner, _parent, _parameters, _node_name):
	
	owner = _owner
	parent = _parent
	parameters = _parameters
	node_name = _node_name
	animation_player = owner.get_node_or_null('AnimationPlayer')
	
	if parent != null and owner.get(parent.parameters + 'playback') != null:
		owner.get(parent.parameters + 'playback').connect('state_starting',Callable(self,'_on_state_starting'))
	
	owner.connect('on_process',Callable(self,'__process'))


	var children = get_children()
	
	for child_name in children:
		
		var child = children[child_name]
		
		if child.has_method('__ready'):

			if child is AnimationNodeStateMachine or \
				child is AnimationNodeBlendTree or \
				child is AnimationNodeBlendSpace1D or \
				child is AnimationNodeBlendSpace2D:
				child.__ready(owner, self, parameters + child_name + '/', child_name)
			else:
				child.__ready(owner, self, parameters, child_name)
		
		
		if child is AnimationNodeAnimation:

			animation_nodes.append(child_name)

		elif child is AnimationNodeStateMachine or \
			child is AnimationNodeBlendTree or \
			child is AnimationNodeBlendSpace1D or \
			child is AnimationNodeBlendSpace2D:
			
			if not child.has_method('_filter_anim_events'):
				continue
			
			statemachine_nodes.append(child_name)
	
	
	var transition_count = get_transition_count()
	var transitions = []
	var anim_names = []

	for idx in range(get_transition_count()):
		
		var from_name = get_transition_from(0)
		var to_name = get_transition_to(0)
		var clone = get_transition(0).duplicate(true)
		
		remove_transition_by_index(0)
		add_transition(from_name, to_name, clone)


	for idx in range(get_transition_count()):

		var transition = get_transition(idx)
		var from_name = get_transition_from(idx)
		var to_name = get_transition_to(idx)
		var from = get_node(from_name)
		var to = get_node(to_name)

		if from.has_method('__ready'):
			from.connections.append(transition)

		if transition.has_method('__ready'):
			transition.__ready(owner, self, parameters, from, to)
		
		#add_transition(from_name, to_name, transition)


func __process(delta):
	
	if advance:
		owner.advance(0.01)
	
	advance = false
