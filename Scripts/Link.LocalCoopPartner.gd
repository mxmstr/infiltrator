extends 'res://Scripts/Link.gd'

export(int) var p1_mouse
export(int) var p1_keyboard
export(int) var p2_mouse
export(int) var p2_keyboard


func _split_viewports(p1_control, p2_control):
	
	var width = get_tree().root.size.x
	var height = get_tree().root.size.y / 2
	
	p1_control.rect_position.y = 0
	p1_control.rect_size.y = height
	p1_control.get_node('Viewport').size.x = width
	p1_control.get_node('Viewport').size.y = height
	p1_control.mouse_device = p1_mouse
	p1_control.keyboard_device = p1_keyboard
	
	p2_control.rect_position.y = height
	p2_control.rect_size.y = height
	p2_control.get_node('Viewport').size.x = width
	p2_control.get_node('Viewport').size.y = height
	p2_control.mouse_device = p2_mouse
	p2_control.keyboard_device = p2_keyboard


func _on_enter():
	
	if get_node(from).has_node('PlayerControl') if has_node(from) else false:
		
		var p1_control = get_node(from).get_node('PlayerControl')
		
		if get_node(to).has_node('PlayerControl') if has_node(to) else false:
			
			var p2_control = get_node(to).get_node('PlayerControl')
			_split_viewports(p1_control, p2_control)


func _on_execute():
	
	_on_enter()