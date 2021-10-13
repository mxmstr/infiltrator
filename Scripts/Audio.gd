extends Node

export(String) var bus

var states = []

signal action


func _start_state(_name, _data={}):
	
	emit_signal('action', _name, _data)
	
#	if states.has(_name):
#		states[_name]._start()
	
#	if not active:
#		return
	
#	if tree_root.has_method('_start'):
#		tree_root._start(_name)


func _ready():
	
	$AudioStreamPlayer3D.bus = bus


#func _process(delta):
#
#	$AudioStreamPlayer3D.unit_db = level
#	$AudioStreamPlayer3D.global_transform.origin = owner.global_transform.origin
