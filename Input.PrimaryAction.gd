extends "res://Scripts/Input.gd"

onready var behavior = get_node_or_null('../Behavior')
onready var righthand = get_node_or_null('../RightHandContainer')

var kick_timer


func _on_active():
	
	if righthand._is_empty():
		
		behavior._start_state('PunchIdle')
		
		if not kick_timer and behavior.current_state == 'PunchIdle':
			kick_timer = get_tree().create_timer(0.75)
	
	#_get_meta().StimulateActor( get_node(CONTAINER).items[0], STIM, self )


func _on_deactive():
	
	kick_timer = null
	
	if righthand._is_empty():
		
		behavior._start_state('Punch')


func _process(delta):
	
	if righthand._is_empty():
		
		if active and kick_timer and kick_timer.time_left <= 0:
			
			behavior._start_state('Kick')
			kick_timer = null