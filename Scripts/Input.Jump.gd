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
	
	var vertical = forward.strength + backward.strength
	var horizontal = left.strength + right.strength
	
	if vertical > 0.2:
		
		behavior._start_state('JumpUp')
	
	elif vertical < -0.5:
		
		behavior._start_state('JumpBackward')
	
	elif vertical <= 0.2 and horizontal < -0.1:
		
		behavior._start_state('JumpRight')
	
	elif vertical <= 0.2 and horizontal > 0.1:
		
		behavior._start_state('JumpLeft')
	
	else:
		
		behavior._start_state('JumpUp')
