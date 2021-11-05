extends "res://Scripts/Input.gd"

var stance


func _on_active():
	
	stance.forward_speed = strength


func _ready():
	
	stance = get_node_or_null('../Stance')