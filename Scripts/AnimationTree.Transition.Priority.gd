extends 'res://Scripts/AnimationTree.Transition.gd'

@export var transition_priority: String


func _on_state_starting(new_name):
	
	pass


func _on_travel_starting(new_node_name, new_node):
	
	if new_node.get('priority') == null:
		advance_mode = AnimationNodeStateMachineTransition.ADVANCE_MODE_DISABLED
		return
	
	advance_mode = new_node.priority > from.priority


func __ready(_owner, _parent, _parameters, _from, _to):
	
	super.__ready(_owner, _parent, _parameters, _from, _to)
	
	if parent != null and owner.get(parent.parameters + 'playback') != null:
		owner.get(parent.parameters + 'playback').connect('state_starting',Callable(self,'_on_state_starting'))
	
	owner.connect('travel_starting',Callable(self,'_on_travel_starting'))
