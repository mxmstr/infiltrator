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
	if current:
		Meta.CreateLink(owner, current, 'Contains', { 'container': 'InventoryContainer' } )
	
	var new = inventory._release(next)
	if new:
		Meta.CreateLink(owner, new, 'Contains', { 'container': 'RightHandContainer' } )
	
	behavior._start_state('Default')


func _find_next(current_rank, not_empty):
	
	var next_item
	var next_rank = 100
	
	for item in inventory.items:
		
		var rank = int(item._get_tag('Rank'))
		var magazine = item.get_node_or_null('Magazine')
		var has_ammo = false if not_empty and magazine and magazine._is_empty() else true
		
		if rank > current_rank and rank < next_rank and has_ammo:
			next_item = item
			next_rank = rank
	
	return next_item


func _find_previous(current_rank, not_empty):
	
	var next_item
	var next_rank = -1
	
	for item in inventory.items:
		
		var rank = int(item._get_tag('Rank'))
		var magazine = item.get_node_or_null('Magazine')
		var has_ammo = false if not_empty and magazine and magazine._is_empty() else true
		
		if rank < current_rank and rank > next_rank and has_ammo:
			next_item = item
			next_rank = rank
	
	return next_item


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
	
	if not link or link._is_invalid():
		return false
	
	behavior._start_state('Default')
	
	return true


func _on_next(forward=true, not_empty=false):
	
	var next_item
	
	if right_hand._is_empty():
		
		if forward:
			next_item = _find_next(-1, not_empty)
		else:
			
			next_item = _find_previous(1000, not_empty)
			
			if next_item and next_item._has_tag('DualWield'):
				
				_go_to_next(next_item)
				_try_dual_wield(next_item)
				
				return
		
		if next_item:
			_go_to_next(next_item)
		
	else:
		
		var current = right_hand.items[0]
		var current_rank = int(current._get_tag('Rank'))
		var dual_wield = current._has_tag('DualWield')
		
		if forward:
			
			if dual_wield:
				
				if Meta.GetLinks(owner, current, 'DualWield').size():
					
					next_item = _find_next(current_rank, not_empty)
				
				else:
					
					if _try_dual_wield(current):
						return
					
					next_item = _find_next(current_rank, not_empty)
				
			else:
				
				next_item = _find_next(current_rank, not_empty)
		
		else:
			
			if dual_wield and Meta.GetLinks(owner, current, 'DualWield').size():
				next_item = current
			
			else:
				
				next_item = _find_previous(current_rank, not_empty)
				
				if next_item and next_item._has_tag('DualWield'):
					
					_go_to_next(next_item)
					_try_dual_wield(next_item)
					
					return
		
		if next_item:
			_go_to_next(next_item)
		else:
			_go_to_unarmed()


func _ready():
	
	next.connect('just_activated', self, '_on_next', [true])
	prev.connect('just_activated', self, '_on_next', [false])
