extends "res://Scripts/Action.8Way.gd"


func _state_end():
	
	stance.stance = stance.StanceType.STANDING


func _process(delta):
	
	if behavior.current_state == state:
		
		_set_blendspace_position()
		
		if behavior.finished and (abs(stance.forward_speed) > 0.1 or abs(stance.sidestep_speed) > 0.1):
			
			behavior._start_state('Default', { 'override': true })
