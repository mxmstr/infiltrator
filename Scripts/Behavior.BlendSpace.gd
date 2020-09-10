extends 'res://Scripts/AnimationTree.BlendSpace.gd'

export(Meta.Priority) var priority
export(Meta.Visibility) var type
export(Meta.Blend) var blend
export var distance = 0.0
export var enable_abilities = true
export var lock_stance = false
export var lock_speed = false
export var lock_direction = false
export var lock_rotation = false
export var lock_movement = false
export var camera_mode = 'LockYaw'


func _is_visible():
	
	return type != Meta.Visibility.INVISIBLE


func _on_state_starting(new_name):
	
	if node_name == new_name:
		
		var playback = owner.get(parent.parameters + 'playback')
		
		if len(playback.get_travel_path()) == 0:
			
			owner.enable_abilities = enable_abilities
			
			if owner.owner.has_node('Stance'):
				owner.owner.get_node('Stance').lock_stance = lock_stance
				owner.owner.get_node('Stance').lock_speed = lock_speed
				owner.owner.get_node('Stance').lock_direction = lock_direction
				owner.owner.get_node('Stance').lock_rotation = lock_rotation
				owner.owner.get_node('Stance').lock_movement = lock_movement
			
			if owner.owner.has_node('Perspective'):
				owner.owner.get_node('Perspective')._start_state(camera_mode)
			
			if owner.owner.has_node('AnimLayerMovement'):
				owner.owner.get_node('AnimLayerMovement').blend_mode = blend
	
	._on_state_starting(new_name)
