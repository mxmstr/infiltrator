extends 'res://AnimationTree.Transition.gd'

export(String) var transition_closest_blend_point

export(String, 'process', 'state_starting') var update_mode = 'process'


func _ready(_owner, _parent, _parameters, _from, _to):
	
	._ready(_owner, _parent, _parameters, _from, _to)
	
	if parent != null and owner.get(parent.parameters + 'playback') != null:
		owner.get(parent.parameters + 'playback').connect('state_starting', self, '_on_state_starting')
	
	owner.connect('on_process', self, '_process')


func _process(delta):
	
	var blend_position = from.parameters + 'blend_position'
	var closest_point = from.get_closest_point(owner.get(blend_position))
	
	from.get_node(closest_point)
	
	#disabled =
