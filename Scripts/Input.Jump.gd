extends "res://Scripts/Input.gd"

var forward
var backward
var right
var left

onready var behavior = get_node_or_null('../Behavior')


func _ready():
	
	forward = get_node_or_null('../MoveForwardInput')
	backward = get_node_or_null('../MoveBackwardInput')
	right = get_node_or_null('../MoveRightInput')
	left = get_node_or_null('../MoveLeftInput')


func _on_just_activated():
	
	if forward.active:
		
		behavior._start_state('JumpUp')
	
	elif backward.active:
		
		behavior._start_state('JumpBackward')
	
	elif not forward.active and left.active:
		
		behavior._start_state('JumpLeft')
	
	elif not forward.active and right.active:
		
		behavior._start_state('JumpRight')
	
	else:
		
		behavior._start_state('JumpUp')
