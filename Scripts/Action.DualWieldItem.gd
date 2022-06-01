extends "res://Scripts/Action.gd"

onready var behavior = $'../Behavior'
onready var inventory = $'../Inventory'


func _dual_wield():
	
	if not is_instance_valid(data.item):
		return
	
	inventory._try_dual_wield(data.item)
