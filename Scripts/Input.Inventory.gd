extends Node

var idx = 0

onready var next = get_node_or_null('../InvNextInput')
onready var prev = get_node_or_null('../InvPrevInput')
onready var right_hand = get_node_or_null('../RightHandContainer')
onready var inventory = get_node_or_null('../InventoryContainer')
onready var behavior = get_node_or_null('../Behavior')


func _swap_items():
	
#	if idx == -1 or inventory._is_empty():
#
#		var current = right_hand._release_front()
#		Meta.CreateLink(owner, current, 'Contains', { 'container': 'InventoryContainer' } )
#
#	else:
	
	var current = right_hand._release_front()
	var new = inventory._release_front()#_release(inventory.items[idx])
	
	Meta.CreateLink(owner, new, 'Contains', { 'container': 'RightHandContainer' } )
	Meta.CreateLink(owner, current, 'Contains', { 'container': 'InventoryContainer' } )
	
	behavior._start_state('Default')


func _on_next():
	
	idx += 1
	
	if idx >= inventory.items.size():
		idx = 0
	
	_swap_items()


func _on_prev():
	
	idx -= 1
	
	if idx == -1:
		idx = inventory.items.size()
	
	_swap_items()


func _ready():
	
	next.connect('just_activated', self, '_on_next')
	prev.connect('just_activated', self, '_on_prev')