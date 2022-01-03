extends 'res://Scripts/Response.gd'

onready var behavior = get_node_or_null('../Behavior')
onready var right_hand = get_node_or_null('../RightHandContainer')
onready var inventory = get_node_or_null('../InventoryInput')


func _on_stimulate(stim, data):
	
	if stim == 'EmptyReact':
		
		behavior._start_state('Reload')
		
		if behavior.current_state != 'Reload':
			inventory._on_next(true, true)
			
			if right_hand._is_empty():
				inventory._on_next(false, true)
			
			if right_hand._is_empty():
				inventory._go_to_unarmed()
