extends "res://Scripts/Action.gd"

onready var inventory = $'../../Inventory'


func _select_item():
	
	inventory._go_to_next()
	
	if data.has('dual_wield'):
		behavior._start_state('DualWieldItem')
