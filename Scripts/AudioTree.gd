extends 'res://Scripts/AnimationTree.gd'


func _start_state(_name, data={}):
	
	print(_name)
	._start_state(_name, data)


func _process(delta):
	
	$AudioStreamPlayer3D.global_transform.origin = owner.global_transform.origin