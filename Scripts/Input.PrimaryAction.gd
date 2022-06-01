extends "res://Scripts/Input.gd"

onready var behavior = get_node_or_null('../Behavior')
onready var righthand = get_node_or_null('../RightHandContainer')

var kick_timer


func _on_just_activated():
	
	if righthand._is_empty():
		
		behavior._start_state('PunchIdle')
		
		if not kick_timer and behavior.current_state == 'PunchIdle':
			kick_timer = get_tree().create_timer(0.5)
	
	else:
		
		if righthand.items[0]._has_tag('Sword'):
			
			behavior._start_state('SwordMelee')
		
		else:
		
			behavior._start_state('UseItem')


func _on_just_deactivated():
	
	kick_timer = null
	
	if righthand._is_empty():
		
		if behavior.current_state == 'PunchIdle':
			behavior._start_state('Punch')


func _process(delta):
	
	righthand.items.size()
	
	if righthand._is_empty():
		
		if active and behavior.current_state == 'PunchIdle' and \
			kick_timer and kick_timer.time_left <= 0:
			
			behavior._start_state('Kick')
			kick_timer = null
	
	else:
		
		if active and righthand.items[0]._has_tag('AutoFire'):
			
			behavior._start_state('UseItem')
