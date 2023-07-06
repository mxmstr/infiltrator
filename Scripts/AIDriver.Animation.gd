extends "res://Scripts/AnimationTree.Animation.gd"

#export var triggers # (Array, Dictionary)

@export var drive_mode = Meta.DriverMode.Steer # (Meta.DriverMode)
@export var move_speed = 0.0
@export var turn_speed = 0.0


func _on_state_starting(new_name):
	
	if node_name == new_name:
		
		var playback = owner.get(parameters + 'playback')
		
		if len(playback.get_travel_path()) == 0:
			
			owner.drive_mode = drive_mode
			owner.move_speed = move_speed
			owner.turn_speed = turn_speed
