extends "res://Scripts/Input.gd"

var stance


func _on_just_activated():
	
	stance.sidestep_speed = strength


func _ready():
	
	stance = get_node_or_null('../Stance')