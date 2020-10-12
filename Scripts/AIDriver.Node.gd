extends "res://Scripts/AnimationTree.Node.gd"

export(Array, Dictionary) var triggers

var drive_mode = DriveMode.Steer
var move_speed = 0
var turn_speed = 0


func _on_state_starting(new_name):
	
	if node_name == new_name:
		
		var playback = owner.get(parameters + 'playback')
		
		if len(playback.get_travel_path()) == 0:
			
			owner.drive_mode = drive_mode
			