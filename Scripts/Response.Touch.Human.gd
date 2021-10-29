extends 'res://Scripts/Response.gd'

onready var righthand = get_node_or_null('../RightHandContainer')


func _on_stimulate(stim, data):
	
	if stim == 'Touch':
		
		if data.source._has_tag('Item'):
			
			if righthand._is_empty():
				
				Meta.CreateLink(owner, data.source, 'Contains')
				
			else:
				
				data.source.get_node('Magazine')._transfer_items_to(owner)
				data.source.get_node('Chamber')._transfer_items_to(owner)
				data.source.get_node('Magazine')._delete_all()
				data.source.get_node('Chamber')._delete_all()
				data.source.queue_free()
		
		elif data.source._has_tag('Ammo'):
			
			var kind = data.source._get_tag('Kind')
			var path = data.source._get_tag('Path')
			var amount = int(data.source._get_tag('Amount'))
			
			for i in range(amount):
				owner.get_node(kind + 'Container')._add_item(kind)
			
			data.source.queue_free()