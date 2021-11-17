extends Node

var stance
var right
var left


func _ready():
	
	stance = get_node_or_null('../Stance')
	right = get_node_or_null('../MoveRightInput')
	left = get_node_or_null('../MoveLeftInput')


func _process(delta):
	
	if not right.active and not left.active:
		
		stance.sidestep_speed = 0.0
