extends "res://Scripts/Action.gd"

onready var inventory = $'../Inventory'


func _select_item():
	
	if not is_instance_valid(data.item):
		return
	
	inventory._go_to_next(data.item)
	
	if data.has('dual_wield'):
		behavior._start_state('DualWieldItem', { 'item': data.item })
