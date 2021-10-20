extends Node

var stance
var forward
var backward


func _ready():
	
	stance = get_node_or_null('../Stance')
	forward = get_node_or_null('../MoveForwardInput')
	backward = get_node_or_null('../MoveBackwardInput')


func _process(delta):
	
	if not forward.active and not backward.active:
		
		stance.forward_speed = 0.0