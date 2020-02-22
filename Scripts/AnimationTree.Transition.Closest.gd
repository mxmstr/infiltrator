extends AnimationNodeStateMachineTransition

export(String) var transition_closest_blend_point

export(String, 'process', 'state_starting') var update_mode = 'process'

var owner
var parent
var parameters
var from
var to


func _ready(_owner, _parent, _parameters, _from, _to):
	
	owner = _owner
	parent = _parent
	parameters = _parameters
	from = _from
	to = _to
	
	owner.connect('on_process', self, '_process')


func _process(delta):
	
	var blend_position = from.parameters + 'blend_position'
	var closest_point = from.get_closest_point(owner.get(blend_position))
	
	from.get_node(closest_point)
	
	#disabled =
