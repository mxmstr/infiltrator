extends 'res://Scripts/StateMachine.gd'


func _process(delta):
	
	$AudioStreamPlayer3D.global_transform.origin = get_parent().global_transform.origin
	
	._process(delta)