extends 'res://Scripts/AnimationTree.Transition.gd'

export(String) var transition_boolean

export(String, 'process', 'state_starting', 'travel_starting') var update_mode = 'process'

export(String, 'True', 'False', 'Null', 'NotNull') var assertion = 'True'
export(String) var target
export(String) var method
export(Array) var args
export(float) var wait_for_frame

var target_node


func _evaluate(value):
	
	var playback = owner.get(parameters + 'playback')
	
	var current_frame = 0 if not playback.is_playing() else playback.get_current_play_pos()
	
	if current_frame < wait_for_frame:
		return false
	
	match assertion:

		'True': return value
		'False': return not value
		'Null': return value == null
		'NotNull': return value != null


func _update():
	
	var _args = []
	
	for arg in args:
		
		if arg is String and arg.begins_with('$'):
			arg = owner.get_indexed(arg.replace('$', ''))
		
		_args.append(arg)
	
	
	disabled = not _evaluate(target_node.callv(method, _args))


func _on_state_starting(new_name):
	
#	if from.get('node_name') == null:
#		return
	
	if from.node_name == new_name and update_mode == 'state_starting':
		_update()


func _on_travel_starting(new_name):
	
	if update_mode == 'travel_starting':
		_update()


func _ready(_owner, _parent, _parameters, _from, _to):
	
	return
	
	._ready(_owner, _parent, _parameters, _from, _to)
	
	target_node = owner.owner.get_node(target)
	
	if parent != null and owner.get(parent.parameters + 'playback') != null:
		owner.get(parent.parameters + 'playback').connect('state_starting', self, '_on_state_starting')
	
	if parent != null and parent.has_user_signal('travel_starting'):
		parent.connect('travel_starting', self, '_on_travel_starting')
	
	owner.connect('on_process', self, '_process')
	
#	if owner.name == 'Behavior' and target == 'RightHandContainer':
#		prints(_owner.owner.name, self)



func _process(delta):
	
	if update_mode == 'process':
		_update()
