extends 'res://Scripts/Response.gd'

onready var righthand = get_node_or_null('../RightHandContainer')
onready var inventory = get_node_or_null('../InventoryContainer')
onready var foley_audio = get_node_or_null('../FoleyAudio')
onready var stamina = get_node_or_null('../Stamina')


func _is_container(node):
	
	if node.get_script():
		return 'Prop.Container.gd' == node.get_script().get_path().get_file()
	
	return false


func _get_ammo_container(magazine, target):
	
	for prop in target.get_children():
		
		if _is_container(prop):
			
			var valid = true
			
			for required_tag in magazine.required_tags_dict.keys():
				if not required_tag in prop.required_tags_dict.keys():
					valid = false
					break
			
			if valid:
				return prop
	
	return null


func _on_stimulate(stim, data):
	
	if stim == 'Touch' and stamina.hp > 0:
		
		if data.source._has_tag('Item'):
			
			foley_audio._start_state('PickupWeapon')
			
			var source_name = data.source.base_name
			var exists = false
			var items_list = inventory.items + ([righthand.items[0]] if not righthand._is_empty() else [])
			
			for item in items_list:
				if item.base_name == source_name:
					exists = true
			
			if exists:
				
				var item_magazine = data.source.get_node('Magazine')
				var item_chamber = data.source.get_node('Chamber')
				var ammo_container = _get_ammo_container(item_magazine, owner)
				
				if not item_magazine._is_empty():
					
					var item_path = item_magazine.items[0]
					
					for i in range(item_magazine.items.size()):
						ammo_container._add_item(item_path)
				
					if not data.source.get_node('Chamber')._is_empty():
						ammo_container._add_item(item_path)
				
				data.source.get_node('Magazine')._delete_all()
				data.source.get_node('Chamber')._delete_all()
				data.source.queue_free()
			
			else:
				
				Meta.CreateLink(owner, data.source, 'Contains')
		
		elif data.source._has_tag('Ammo'):
			
			foley_audio._start_state('PickupAmmo')
			
			var kind = data.source._get_tag('Kind')
			var path = data.source._get_tag('Path')
			var amount = int(data.source._get_tag('Amount'))
			
			for i in range(amount):
				owner.get_node(kind + 'Container')._add_item(path)
			
			data.source.queue_free()
