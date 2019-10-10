extends AnimationNodeStateMachineTransition

export(float) var min_intensity
export(float) var max_intensity
export(Vector3) var direction
export(float) var max_direction_angle = -1

var parent


func _on_travel_starting(_collider, _position, _normal, _travel):
	
	var within_intensity = _travel.length() > min_intensity and _travel.length() < max_intensity
	
	var local_travel = parent.get_parent().global_transform.basis.xform(_travel)
	var within_direction = max_direction_angle == -1 or \
		local_travel.angle_to(direction) < deg2rad(max_direction_angle)
	
	disabled = not within_intensity or not within_direction


func _ready(_parent):
	
	parent = _parent
	
	parent.connect('on_process', self, '_process')
	parent.connect('travel_starting', self, '_on_travel_starting')


func _process():
	
	pass