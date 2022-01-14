extends Node

onready var next = get_node_or_null('../InvNextInput')
onready var prev = get_node_or_null('../InvPrevInput')
onready var right_hand = get_node_or_null('../RightHandContainer')
onready var inventory = get_node_or_null('../InventoryContainer')
onready var behavior = get_node_or_null('../Behavior')


func _go_to_unarmed():
	
	var current = right_hand._release_front()
	
	if current:
		Meta.CreateLink(owner, current, 'Contains', { 'container': 'InventoryContainer' } )


func _go_to_next(next):
	
	var current = right_hand._release_front()
	var new = inventory._release(next)
	
	if new:
		Meta.CreateLink(owner, new, 'Contains', { 'container': 'RightHandContainer' } )
	
	if current:
		Meta.CreateLink(owner, current, 'Contains', { 'container': 'InventoryContainer' } )
	
	behavior._start_state('Default')


func _on_next(forward=true, not_empty=false):
	
	if right_hand._is_empty():
		
		var next
		
		if forward:
			
			var lowest_rank = 100
			
			for item in inventory.items:
				
				var rank = int(item._get_tag('Rank'))
				var magazine = item.get_node_or_null('Magazine')
				var has_ammo = false if not_empty and magazine and magazine._is_empty() else true
				
				if rank < lowest_rank and has_ammo:
					next = item
					lowest_rank = rank
		
		else:
			
			var highest_rank = -1
			
			for item in inventory.items:
				
				var rank = int(item._get_tag('Rank'))
				var magazine = item.get_node_or_null('Magazine')
				var has_ammo = false if not_empty and magazine and magazine._is_empty() else true
				
				if rank >= highest_rank and has_ammo:
					next = item
					highest_rank = rank
		
		if next:
			_go_to_next(next)
		
	else:
		
		var current = right_hand.items[0]
		var current_rank = int(current._get_tag('Rank'))
		var next
		
		if forward:
			
			var next_rank = 100
			
			for item in inventory.items:
				
				var rank = int(item._get_tag('Rank'))
				var magazine = item.get_node_or_null('Magazine')
				var has_ammo = false if not_empty and magazine and magazine._is_empty() else true
				
				if rank > current_rank and rank < next_rank and has_ammo:
					next = item
					next_rank = rank
		
		else:
			
			var next_rank = -1
			
			for item in inventory.items:
				
				var rank = int(item._get_tag('Rank'))
				var magazine = item.get_node_or_null('Magazine')
				var has_ammo = false if not_empty and magazine and magazine._is_empty() else true
				
				if rank < current_rank and rank > next_rank and has_ammo:
					next = item
					next_rank = rank
		
		if next:
			_go_to_next(next)
		else:
			_go_to_unarmed()


func _ready():
	
	next.connect('just_activated', self, '_on_next', [true])
	prev.connect('just_activated', self, '_on_next', [false])
