extends 'res://Scripts/AnimationTree.Node.gd'

export(Meta.Priority) var priority
export(Meta.Visibility) var type
export(Meta.Blend) var blend
export var speed = 1.0
export var distance = 0.0
export var abilities = true
export var movement = true
export var rotation = true
export var camera_mode = 'LockYaw'


func _is_visible():
	
	return type != Meta.Visibility.INVISIBLE


func _on_state_starting(new_name):
	
	if node_name == new_name:
		
		#emit_signal('state_starting')
		
		var playback = owner.get(parameters + 'playback')
		
		if len(playback.get_travel_path()) == 0:
		
			owner.enable_abilities = abilities
			
			if owner.owner.has_node('Movement'):
				owner.owner.get_node('Movement').enable_movement = movement
				owner.owner.get_node('Movement').enable_rotation = rotation
			
			if owner.owner.has_node('Perspective'):
				owner.owner.get_node('Perspective')._start_state(camera_mode)
