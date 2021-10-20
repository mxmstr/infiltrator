extends Node

var stance
var up
var down


func _ready():
	
	stance = get_node_or_null('../Stance')
	up = get_node_or_null('../RotateUpInput')
	down = get_node_or_null('../RotateDownInput')


func _process(delta):
	
	if not up.active and not down.active:
		
		stance._set_look_speed(0.0)