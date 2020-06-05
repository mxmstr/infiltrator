extends 'res://Scripts/AnimationTree.gd'

export(float) var level


func _start_state(_name, data={}):
	
	._start_state(_name, data)


func _process(delta):
	
	$AudioStreamPlayer3D.unit_db = level
	$AudioStreamPlayer3D.global_transform.origin = owner.global_transform.origin
