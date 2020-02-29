extends AnimationNodeStateMachineTransition

export(float) var min_intensity
export(float) var max_intensity
export(Vector3) var direction
export(float) var max_direction_angle = -1

var owner
var parent
var parameters
var connections = []
var from
var to


func _on_stimulate(_collider, _position, _normal, _travel):
	
	var intensity = _travel.length() * 10000
	
	var within_intensity = intensity >= min_intensity and intensity <= max_intensity
	
	var local_direction = owner.get_parent().global_transform.basis.xform(direction)
	var within_direction = max_direction_angle == -1 or \
		_normal.angle_to(local_direction) < deg2rad(max_direction_angle)
	
	disabled = not within_intensity or not within_direction


func _ready(_owner, _parent, _parameters, _from, _to):
	
	owner = _owner
	parent = _parent
	parameters = _parameters
	from = _from
	to = _to
	
	owner.connect('on_stimulate', self, '_on_stimulate')
