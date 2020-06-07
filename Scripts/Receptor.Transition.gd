extends AnimationNodeStateMachineTransition

export(float) var min_intensity
export(float) var max_intensity
export(Vector3) var within_direction
export(float) var max_direction_angle = -1

var owner
var parent
var parameters
var connections = []
var from
var to


func _on_stimulate(collider, position, direction, intensity):
	
	intensity *= 10000
	
	var has_intensity = intensity >= min_intensity and intensity <= max_intensity
	
	var local_within_direction = owner.get_parent().global_transform.basis.xform(within_direction)
	var has_direction = max_direction_angle == -1 or direction.angle_to(local_within_direction) < deg2rad(max_direction_angle)
	
	disabled = not has_intensity or not has_direction


func _ready(_owner, _parent, _parameters, _from, _to):
	
	owner = _owner
	parent = _parent
	parameters = _parameters
	from = _from
	to = _to
	
	owner.connect('on_stimulate', self, '_on_stimulate')
