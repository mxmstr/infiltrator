extends 'res://Scripts/Response.gd'

onready var righthand = get_node_or_null('../RightHandContainer')
onready var inventory = get_node_or_null('../InventoryContainer')
onready var foley_audio = get_node_or_null('../FoleyAudio')


func _on_stimulate(stim, data):
	
	if stim == 'Touch':
		
		if data.source._has_tag('Item'):
			
			foley_audio._start_state('PickupWeapon')
			
			var source_name = data.source.base_name
			var exists = false
			var items_list = inventory.items + ([righthand.items[0]] if not righthand._is_empty() else [])
			
			for item in items_list:
				if item.base_name == source_name:
					exists = true
			
			if exists:
				
				data.source.get_node('Magazine')._transfer_items_to(owner)
				data.source.get_node('Chamber')._transfer_items_to(owner)
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