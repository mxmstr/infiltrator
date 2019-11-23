extends AnimationNodeBlendSpace2D

export(String) var x_target
export(String) var x_method
export(float) var x_max_value
export(float) var x_min_value

export(String) var y_target
export(String) var y_method
export(float) var y_max_value
export(float) var y_min_value

var node_name
var parent
var playback
var transitions = []


func _on_state_starting(new_name):
	
	if node_name == new_name:
		
		var x_value = parent.owner.get_node(x_target).call(x_method)
		x_value = (((x_value - x_min_value) / (x_max_value - x_min_value)) * 2) - 1
		
		var y_value = parent.owner.get_node(y_target).call(y_method)
		y_value = (((y_value - y_min_value) / (y_max_value - y_min_value)) * 2) - 1
		
		parent.set('parameters/' + node_name + '/blend_position', Vector2(x_value, y_value))


func _ready(_parent, _playback, _node_name):
	
	parent = _parent
	playback = _playback
	node_name = _node_name
	
	parent.connect('state_starting', self, '_on_state_starting')