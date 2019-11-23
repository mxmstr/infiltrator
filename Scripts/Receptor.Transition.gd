extends AnimationNodeStateMachineTransition

export(float) var min_intensity
export(float) var max_intensity
export(Vector3) var direction
export(float) var max_direction_angle = -1

var parent
var playback
var from
var to


func _on_stimulate(_collider, _position, _normal, _travel):
	
	var within_intensity = _travel.length() > min_intensity and _travel.length() < max_intensity
	
	var local_travel = parent.get_parent().global_transform.basis.xform(_travel)
	var within_direction = max_direction_angle == -1 or \
		local_travel.angle_to(direction) < deg2rad(max_direction_angle)
	
	disabled = not within_intensity or not within_direction


func _ready(_parent, _playback, _from, _to):
	
	parent = _parent
	playback = _playback
	from = _from
	to = _to
	
	parent.connect('on_stimulate', self, '_on_stimulate')