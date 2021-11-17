extends Node

var stance
var right
var left


func _ready():
	
	stance = get_node_or_null('../Stance')
	right = get_node_or_null('../RotateRightInput')
	left = get_node_or_null('../RotateLeftInput')


func _process(delta):
	
	if not right.active and not left.active:
		
		stance._set_turn_speed(0.0)
