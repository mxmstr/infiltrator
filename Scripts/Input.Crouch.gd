extends "res://Scripts/Input.gd"

const roll_timeout = 0.25

var roll_input_timeout = false
var roll_input_active = false

onready var stance = get_node_or_null('../Stance')
onready var forward = get_node_or_null('../MoveForwardInput')
onready var backward = get_node_or_null('../MoveBackwardInput')
onready var right = get_node_or_null('../MoveRightInput')
onready var left = get_node_or_null('../MoveLeftInput')
onready var behavior = get_node_or_null('../Behavior')
onready var movement = get_node_or_null('../Movement')


func _on_roll_timeout():
	
	roll_input_timeout = true


func _roll():
	
	var vertical = forward.strength + backward.strength
	var horizontal = left.strength + right.strength
	
	if vertical > 0.9:
		
		behavior._start_state('RollForward')
	
	elif vertical < -0.9:
		
		behavior._start_state('RollBackward')
	
	elif abs(vertical) <= 0.2 and horizontal < -0.9:
		
		behavior._start_state('RollRight')
	
	elif abs(vertical) <= 0.2 and horizontal > 0.9:
		
		behavior._start_state('RollLeft')


func _on_just_activated():
	
	stance.stance = stance.StanceType.CROUCHING
	
#	if strength > 0.9:
#		get_tree().create_timer(roll_timeout).connect('timeout', self, '_on_roll_timeout')


func _on_just_deactivated():
	
	stance.stance = stance.StanceType.STANDING


func _process(delta):
	
	if roll_input_active:
		
		if roll_input_timeout and strength < 0.9:
			roll_input_active = false
		
		elif not roll_input_timeout and strength < 0.9 and strength > 0.1:
			_roll()
	
	elif strength > 0.9:
		
		roll_input_active = true
		roll_input_timeout = false
		get_tree().create_timer(roll_timeout).connect('timeout', self, '_on_roll_timeout')
