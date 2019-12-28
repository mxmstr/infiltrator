extends 'res://Scripts/StateMachine.BlendSpace.gd'

export(Inf.Priority) var priority
export(Inf.Visibility) var type
export(Inf.Blend) var blend
export var distance = 0.0
export var abilities = true
export var movement = true
export var rotation = true
export var camera_mode = 'LockYaw'


func _is_visible():
	
	return type != Inf.Visibility.INVISIBLE


func _on_state_starting(new_name):
	
	if node_name == new_name:
		
		var playback = parent.get(parameters + '/playback')
		
		if len(playback.get_travel_path()) == 0:
			
			if parent.owner.has_node('InputAbilities'):
				parent.owner.get_node('InputAbilities').active = abilities
			
			if parent.owner.has_node('InputMovement'):
				parent.owner.get_node('InputMovement').active = movement
			
			if parent.owner.has_node('InputRotation'):
				parent.owner.get_node('InputRotation').active = rotation
			
			if parent.owner.has_node('Perspective'):
				parent.owner.get_node('Perspective')._start_state(camera_mode)
	
	._on_state_starting(new_name)