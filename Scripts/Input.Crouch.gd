extends "res://Scripts/Input.gd"

var stance


func _on_just_activated():
	
	stance.stance = stance.StanceType.CROUCHING


func _on_just_deactivated():
	
	stance.stance = stance.StanceType.STANDING


func _ready():
	
	stance = get_node_or_null('../Stance')