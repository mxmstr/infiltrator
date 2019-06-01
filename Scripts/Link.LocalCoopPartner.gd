extends 'res://Scripts/Link.gd'


func _split_viewports(sender_control, receiver_control):
	
	var width = get_tree().root.size.x
	var height = get_tree().root.size.y / 2
	
	sender_control.rect_position.y = 0
	sender_control.rect_size.y = height
	sender_control.get_node('Viewport').size.x = width
	sender_control.get_node('Viewport').size.y = height
	
	receiver_control.rect_position.y = height
	receiver_control.rect_size.y = height
	receiver_control.get_node('Viewport').size.x = width
	receiver_control.get_node('Viewport').size.y = height


func _on_enter():
	
	for sender in from:
		
		if has_node(sender) and get_node(sender).has_node('PlayerControl'):
			
			var sender_control = get_node(sender).get_node('PlayerControl')
			
			for receiver in to:
				
				if has_node(sender) and get_node(sender).has_node('PlayerControl'):
					
					var receiver_control = get_node(receiver).get_node('PlayerControl')
					_split_viewports(sender_control, receiver_control)


func _on_execute():
	
	_on_enter()