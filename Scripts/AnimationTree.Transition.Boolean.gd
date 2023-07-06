extends 'res://Scripts/AnimationTree.Transition.gd'

@export var transition_boolean: String

@export_enum('process', 'state_starting', 'travel_starting') var update_mode = 'process'
@export_enum('True', 'False', 'Null', 'NotNull') var assertion = 'True'
@export var target: String
@export var method: String
@export var args: Array
@export var wait_for_frame: float

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
	
	
	advance_mode = _evaluate(target_node.callv(method, _args))


func _on_state_starting(new_name):
	
	if from.node_name == new_name and update_mode == 'state_starting':
		_update()


func _on_travel_starting(new_name):
	
	if update_mode == 'travel_starting':
		_update()


func __ready(_owner, _parent, _parameters, _from, _to):
	
	super.__ready(_owner, _parent, _parameters, _from, _to)
	
	target_node = owner.owner.get_node(target)
	
	if parent != null and owner.get(parent.parameters + 'playback') != null:
		owner.get(parent.parameters + 'playback').connect('state_starting',Callable(self,'_on_state_starting'))
	
	if parent != null and parent.has_user_signal('travel_starting'):
		parent.connect('travel_starting',Callable(self,'_on_travel_starting'))
	
	owner.connect('on_process',Callable(self,'__process'))


func __process(delta):
	
	if update_mode == 'process':
		_update()
