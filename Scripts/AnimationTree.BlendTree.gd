tool
extends AnimationNodeBlendTree

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
	
	pass


func _unfilter_anim_events():
	
	pass


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


func _ready(_owner, _parent, _parameters, _node_name):
	
	owner = _owner
	parent = _parent
	parameters = _parameters
	node_name = _node_name
	
#	if parent != null and owner.get(parent.parameters + 'playback') != null:
#		owner.get(parent.parameters + 'playback').connect('state_starting', self, '_on_state_starting')
	
	owner.connect('on_process', self, '_process')


	var children = get_children()

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


func _process(delta):
	
	if advance:
		owner.advance(0.01)
	
	advance = false
