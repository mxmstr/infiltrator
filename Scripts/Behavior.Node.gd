extends AnimationNodeAnimation

export(Inf.Priority) var priority
export(Inf.Visibility) var type
export(Inf.Blend) var blend_mode
export var speed = 1.0
export var distance = 0.0

var node_name
var parent
var transitions = []


func _is_visible():
	
	return type != Inf.Visibility.INVISIBLE


func _on_state_starting(new_name):
	
	if node_name == new_name:
		
		parent.get_node('AnimationPlayer').playback_speed = speed


func _ready(_parent, _node_name):
	
	parent = _parent
	node_name = _node_name
	
	parent.connect('state_starting', self, '_on_state_starting')