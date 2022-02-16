extends "res://Scripts/Input.gd"

var wall_run_direction

onready var forward = get_node_or_null('../MoveForwardInput')
onready var backward = get_node_or_null('../MoveBackwardInput')
onready var right = get_node_or_null('../MoveRightInput')
onready var left = get_node_or_null('../MoveLeftInput')
onready var behavior = get_node_or_null('../Behavior')
onready var movement = get_node_or_null('../Movement')


func _on_just_activated():
	
	for slide in movement.collisions:
		if slide.on_wall:
			behavior._start_state('WallRun', { 'normal': slide.normal })
			return
	
	var test_collision = movement._test_movement(movement.direction * 1.5)
	
	if test_collision and test_collision.on_wall:
		behavior._start_state('WallRun', { 'normal': test_collision.normal })
		return
	
	
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
	
	elif vertical < -0.2:
		
		behavior._start_state('JumpBackward')
	
	else:
		
		behavior._start_state('JumpUp')


func _on_just_deactivated():
	
	behavior._start_state('WallRunEnd')
