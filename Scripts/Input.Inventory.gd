extends Node

var idx = -1

onready var next = get_node_or_null('../InvNextInput')
onready var prev = get_node_or_null('../InvPrevInput')
onready var right_hand = get_node_or_null('../RightHandContainer')
onready var inventory = get_node_or_null('../InventoryContainer')
onready var behavior = get_node_or_null('../Behavior')


func _swap_items():
	
	if idx == -1:# or inventory._is_empty():

		var current = right_hand._release_front()
		
		if current:
			Meta.CreateLink(owner, current, 'Contains', { 'container': 'InventoryContainer' } )

	else:
		
		var current = right_hand._release_front()
		var new = inventory._release_front()#_release(inventory.items[idx])
		
		if new:
			Meta.CreateLink(owner, new, 'Contains', { 'container': 'RightHandContainer' } )
		
		if current:
			Meta.CreateLink(owner, current, 'Contains', { 'container': 'InventoryContainer' } )
		
		behavior._start_state('Default')


func _on_next():
	
	idx += 1
	
	var equipped = 1 if not right_hand._is_empty() else 0
	
	if idx >= inventory.items.size() + equipped:
		idx = -1
	
	_swap_items()


func _on_prev():
	
	idx -= 1
	
	var equipped = 1 if not right_hand._is_empty() else 0
	
	if idx < -1:
		idx = inventory.items.size() - 1 + equipped
	
	_swap_items()


func _ready():
	
	next.connect('just_activated', self, '_on_next')
	prev.connect('just_activated', self, '_on_prev')