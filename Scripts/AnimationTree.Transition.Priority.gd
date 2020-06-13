extends 'res://Scripts/AnimationTree.Transition.gd'

export(String) var transition_priority


func _on_state_starting(new_name):
	
	pass


func _on_travel_starting(new_node_name, new_node):
	
	if new_node.get('priority') == null:
		disabled = true
		return
	
	disabled = not new_node.priority > from.priority


func _ready(_owner, _parent, _parameters, _from, _to):
	
	._ready(_owner, _parent, _parameters, _from, _to)
	
	if parent != null and owner.get(parent.parameters + 'playback') != null:
		owner.get(parent.parameters + 'playback').connect('state_starting', self, '_on_state_starting')
	
	owner.connect('travel_starting', self, '_on_travel_starting')
