extends 'res://Scripts/AnimationTree.gd'

export(String) var bus
export(float) var level


func _start_state(_name, data={}):
	
	if not active:
		return
	
	if tree_root.has_method('_start'):
		tree_root._start(_name)


func _ready():
	
	$AudioStreamPlayer3D.bus = bus


func _process(delta):
	
	$AudioStreamPlayer3D.unit_db = level
	$AudioStreamPlayer3D.global_transform.origin = owner.global_transform.origin
