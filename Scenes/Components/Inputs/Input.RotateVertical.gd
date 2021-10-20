extends "res://Scripts/Input.gd"

var stance


func _on_just_activated():
	
	stance._set_look_speed(strength)


func _ready():
	
	stance = get_node_or_null('../Stance')