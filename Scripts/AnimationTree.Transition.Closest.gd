extends 'res://Scripts/AnimationTree.Transition.gd'

@export var transition_closest_blend_point: String

@export_enum('process', 'state_starting') var update_mode = 'process'


func __ready(_owner, _parent, _parameters, _from, _to):
	
	super.__ready(_owner, _parent, _parameters, _from, _to)
	
	if parent != null and owner.get(parent.parameters + 'playback') != null:
		owner.get(parent.parameters + 'playback').connect('state_starting',Callable(self,'_on_state_starting'))
	
	owner.connect('on_process',Callable(self,'__process'))


func __process(delta):
	
	var blend_position = from.parameters + 'blend_position'
	var closest_point = from.get_closest_point(owner.get(blend_position))
	
	from.get_node(closest_point)
