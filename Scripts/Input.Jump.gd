extends "res://Scripts/Input.gd"

var wall_run_direction

onready var primary = get_node_or_null('../PrimaryActionInput')
onready var forward = get_node_or_null('../MoveForwardInput')
onready var backward = get_node_or_null('../MoveBackwardInput')
onready var right = get_node_or_null('../MoveRightInput')
onready var left = get_node_or_null('../MoveLeftInput')
onready var behavior = get_node_or_null('../Behavior')
onready var movement = get_node_or_null('../Movement')
onready var stance = get_node_or_null('../Stance')


func _try_wallrun():
	
	var vertical = forward.strength + backward.strength
	
	if vertical > 0.2:
		
		for slide in movement.collisions:
			if slide.on_wall:
				behavior._start_state('WallRun', { 'normal': slide.normal })
				return true
		
		var test_collision = movement._test_movement(movement.direction * 1.5)
		
		if test_collision and test_collision.on_wall:
			behavior._start_state('WallRun', { 'normal': test_collision.normal })
			return true
	
	return false


func _jump():
	
	var vertical = forward.strength + backward.strength
	var horizontal = left.strength + right.strength
	var speed_percent = min(movement.velocity.length() / stance.max_speed, 1.0)
	var running = speed_percent > 0.4
	var action = 'JumpUp'
	
	if vertical < -0.2:
		
		if running:
			
			if horizontal > 0.1:
				action = 'AirDodgeBackwardLeft'
			elif horizontal < -0.1:
				action = 'AirDodgeBackwardRight'
			else:
				action = 'AirDodgeBackward'
		
		else:
			
			if horizontal > 0.1:
				action = 'JumpBackwardLeft'
			elif horizontal < -0.1:
				action = 'JumpBackwardRight'
			else:
				action = 'JumpBackward'
	
	elif abs(vertical) <= 0.2 and horizontal < -0.1:
		
		if running:
			action = 'AirDodgeRight'
		else:
			action = 'JumpRight'
	
	elif abs(vertical) <= 0.2 and horizontal > 0.1:
		
		if running:
			action = 'AirDodgeLeft'
		else:
			action = 'JumpLeft'
	
	behavior._start_state(action)


func _on_just_activated():
	
	if _try_wallrun():
		return
	
	behavior._start_state('PreJump')


#func _on_active():
#
#	if behavior.current_state == 'PreJump':
#
#		#prints(get_process_delta_time(), primary.strength)
#		if primary.active:
#
#			var vertical = forward.strength + backward.strength
#			var horizontal = left.strength + right.strength
#
#			behavior._start_state('ShootDodgeAir', { 'direction': Vector2(horizontal, vertical) })


func _on_just_deactivated():
	
	if behavior.current_state == 'PreJump':
		
		if owner.is_on_floor():
			_jump()
		else:
			behavior._start_state('Default')
	
	elif behavior.current_state == 'WallRun':
		
		behavior._start_state('WallRunEnd')


func _process(delta):
	
	if active:
		
		if behavior.current_state == 'PreJump':
			
			if primary.active:
				
				var vertical = forward.strength + backward.strength
				var horizontal = left.strength + right.strength
				
				behavior._start_state('ShootDodgeAir', { 'direction': Vector2(horizontal, vertical) })
