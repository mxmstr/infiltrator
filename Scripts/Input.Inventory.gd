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


func _find_next(current_rank, not_empty):
	
	var next
	var next_rank = 100
	
	for item in inventory.items:
		
		var rank = int(item._get_tag('Rank'))
		var magazine = item.get_node_or_null('Magazine')
		var has_ammo = false if not_empty and magazine and magazine._is_empty() else true
		
		if rank > current_rank and rank < next_rank and has_ammo:
			next = item
			next_rank = rank
	
	return next


func _find_previous(current_rank, not_empty):
	
	var next_rank = -1
	
	for item in inventory.items:
		
		var rank = int(item._get_tag('Rank'))
		var magazine = item.get_node_or_null('Magazine')
		var has_ammo = false if not_empty and magazine and magazine._is_empty() else true
		
		if rank < current_rank and rank > next_rank and has_ammo:
			next = item
			next_rank = rank


func _is_container(node):
	
	if node.get_script() != null:
		
		var script_name = node.get_script().get_path().get_file()
		return script_name == 'Prop.Container.gd'
	
	return false


func _get_ammo_container(item):
	
	var required_tags = item.get_node('Magazine').required_tags_dict.keys()
	var container
	var best_tag_count = 0
	
	for prop in owner.get_children():
		
		if _is_container(prop):
			
			var tag_count = 0
			
			for required_tag in required_tags:
				if required_tag in prop.required_tags_dict.keys():
					tag_count += 1
			
			if tag_count > best_tag_count:
				
				container = prop
				best_tag_count = tag_count
	
	return container


func _try_dual_wield(current):
	
	var ammo_container = _get_ammo_container(current)
	var inv_ammo = ammo_container.items.size()
	var clip_size = current.get_node('Magazine').max_quantity
	
	if inv_ammo < clip_size:
		return false
	
	var link = Meta.CreateLink(owner, current, 'DualWield')
	
	return not link._is_invalid() if link else false


func _on_next(forward=true, not_empty=false):
	
	var next
	
	if right_hand._is_empty():
		
		if forward:
			next = _find_next(-1, not_empty)
		else:
			next = _find_previous(-1, not_empty)
		
		if next:
			_go_to_next(next)
		
	else:
		
		var current = right_hand.items[0]
		var current_rank = int(current._get_tag('Rank'))
		var dual_wield = current._has_tag('DualWield')
		
		if forward:
			
			if dual_wield and not Meta.GetLinks(owner, current, 'DualWield').size():
				
#				if _try_dual_wield(current):
#					return
				
				next = _find_next(current_rank, not_empty)
				
			else:
				
				next = _find_next(current_rank, not_empty)
		
		else:
			
			next = _find_previous(current_rank, not_empty)
		
		if next:
			_go_to_next(next)
		else:
			_go_to_unarmed()


func _ready():
	
	next.connect('just_activated', self, '_on_next', [true])
	prev.connect('just_activated', self, '_on_next', [false])
