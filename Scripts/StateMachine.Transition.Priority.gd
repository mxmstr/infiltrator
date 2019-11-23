extends AnimationNodeStateMachineTransition

var parent
var playback
var from
var to


func _on_travel_starting(new_node_name, new_node):
	
	disabled = not new_node.priority > from.priority


func _ready(_parent, _playback, _from, _to):
	
	parent = _parent
	playback = _playback
	from = _from
	to = _to
	
	parent.connect('travel_starting', self, '_on_travel_starting')