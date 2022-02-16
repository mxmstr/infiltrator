extends "res://Scripts/Action.gd"

var active = false

onready var movement = $'../Movement'
onready var stance = $'../Stance'


func _on_action(_state, _data):
	
	if _state == 'WallRun':
		
		data = _data
		stance.mode = stance.Mode.WALLRUN
		stance.wall_normal = data.normal
		active = true
	
	elif _state == 'WallRunEnd':
		
		stance.mode = stance.Mode.DEFAULT
		active = false


func _process(delta):
	
	if not active:
		return

#	if not owner.is_on_wall():
#
#		stance.mode = stance.Mode.DEFAULT
#		active = false
#
#		return
