extends AnimationNodeAnimation

export(Inf.Priority) var priority
export(Inf.Visibility) var type
export(Inf.Blend) var blend_mode
export var speed = 1.0
export var distance = 0.0
export var abilities = true
export var movement = true
export var rotation = true
export var cam_max_x = 0.0
export var cam_max_y = PI / 2

var node_name
var parent
var transitions = []


func _is_visible():
	
	return type != Inf.Visibility.INVISIBLE


func _on_state_starting(new_name):
	
	if node_name == new_name:
		
		parent.get_node('AnimationPlayer').playback_speed = speed
		
		if parent.owner.has_node('InputAbilities'):
			parent.owner.get_node('InputAbilities').active = abilities
		
		if parent.owner.has_node('InputMovement'):
			parent.owner.get_node('InputMovement').active = movement
		
		if parent.owner.has_node('InputRotation'):
			parent.owner.get_node('InputRotation').active = rotation
		
		if parent.owner.has_node('Perspective'):
			parent.owner.get_node('Perspective').cam_max_x = cam_max_x
			parent.owner.get_node('Perspective').cam_max_y = cam_max_y


func _ready(_parent, _node_name):
	
	parent = _parent
	node_name = _node_name
	
	parent.connect('state_starting', self, '_on_state_starting')