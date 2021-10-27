extends "res://Scripts/Input.gd"

onready var behavior = get_node_or_null('../Behavior')
onready var righthand = get_node_or_null('../RightHandContainer')

var kick_timer


func _on_just_activated():
	
	if righthand._is_empty():
		
		behavior._start_state('PunchIdle')
		
		if not kick_timer and behavior.current_state == 'PunchIdle':
			kick_timer = get_tree().create_timer(0.75)
	
	else:
		
		Meta.StimulateActor(righthand.items[0], 'Use', owner)


func _on_just_deactivated():
	
	kick_timer = null
	
	if righthand._is_empty():
		
		if behavior.current_state == 'PunchIdle':
			behavior._start_state('Punch')


func _process(delta):
	
	if righthand._is_empty():
		
		if active and behavior.current_state == 'PunchIdle' and \
			kick_timer and kick_timer.time_left <= 0:
			
			behavior._start_state('Kick')
			kick_timer = null