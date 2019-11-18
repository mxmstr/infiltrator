extends 'res://Scripts/StateMachine.gd'


func _process(delta):
	
	$AudioStreamPlayer3D.global_transform.origin = owner.global_transform.origin