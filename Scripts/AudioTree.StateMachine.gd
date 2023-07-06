extends 'res://Scripts/AnimationTree.StateMachine.gd'

@export var level: float


func _on_state_starting(new_name):
	
	super._on_state_starting(new_name)
	
	if node_name == new_name:
		
		var playback = owner.get(parameters + 'playback')
		
		if len(playback.get_travel_path()) == 0:
			owner.level = level
