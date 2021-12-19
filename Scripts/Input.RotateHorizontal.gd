extends "res://Scripts/Input.gd"

var stance


func _on_just_activated():
	
	stance._set_turn_speed(strength * Meta.rotate_sensitivity)


func _on_active():
	
	stance._set_turn_speed(strength * Meta.rotate_sensitivity)


func _ready():
	
	stance = get_node_or_null('../Stance')
