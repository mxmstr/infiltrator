extends "res://Scripts/Input.gd"

var stance


func _on_active():
	
	stance._set_look_speed(strength * Meta.rotate_sensitivity)


func _ready():
	
	stance = get_node_or_null('../Stance')