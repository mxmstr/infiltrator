extends 'res://Scripts/AnimationTree.BlendSpace.gd'

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
		
		var playback = owner.get(parameters + '/playback')
		
		if len(playback.get_travel_path()) == 0:
			
			if owner.owner.has_node('InputAbilities'):
				owner.owner.get_node('InputAbilities').active = abilities
			
			if owner.owner.has_node('InputMovement'):
				owner.owner.get_node('InputMovement').active = movement
			
			if owner.owner.has_node('InputRotation'):
				owner.owner.get_node('InputRotation').active = rotation
			
			if owner.owner.has_node('Perspective'):
				owner.owner.get_node('Perspective')._start_state(camera_mode)
	
	._on_state_starting(new_name)