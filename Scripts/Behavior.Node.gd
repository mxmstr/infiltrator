extends AnimationNodeAnimation

export(Inf.Priority) var priority
export(Inf.Visibility) var type
export(Inf.Blend) var blend
export var speed = 1.0
export var distance = 0.0
export var abilities = true
export var movement = true
export var rotation = true
export var camera_mode = 'LockYaw'

var node_name
var parent
var playback
var transitions = []


func _is_visible():
	
	return type != Inf.Visibility.INVISIBLE


func _on_state_starting(new_name):
	
	if node_name == new_name:
		
		if len(playback.get_travel_path()) == 0:
		
			parent.get_node('AnimationPlayer').playback_speed = speed
			
			if parent.owner.has_node('InputAbilities'):
				parent.owner.get_node('InputAbilities').active = abilities
			
			if parent.owner.has_node('InputMovement'):
				parent.owner.get_node('InputMovement').active = movement
			
			if parent.owner.has_node('InputRotation'):
				parent.owner.get_node('InputRotation').active = rotation
			
			if parent.owner.has_node('Perspective'):
				parent.owner.get_node('Perspective')._start_state(camera_mode)


func _ready(_parent, _playback, _node_name):
	
	parent = _parent
	playback = _playback
	node_name = _node_name
	
	parent.connect('state_starting', self, '_on_state_starting')