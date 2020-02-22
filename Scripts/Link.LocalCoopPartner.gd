extends 'res://Scripts/Link.gd'


func _split_viewports(p1_control, p2_control):
	
	var width = get_tree().root.size.x
	var height = get_tree().root.size.y / 2
	
	p1_control.get_node('Container').rect_position.y = 0
	p1_control.get_node('Container').rect_size.y = height
	p1_control.get_node('Container/Viewport').size.x = width
	p1_control.get_node('Container/Viewport').size.y = height
	p1_control.player_index = 0
	p1_control.mouse_device = Inf.p1_mouse
	p1_control.keyboard_device = Inf.p1_keyboard
	
	p1_control._reset_viewport()
	
	p2_control.get_node('Container').rect_position.y = height
	p2_control.get_node('Container').rect_size.y = height
	p2_control.get_node('Container/Viewport').size.x = width
	p2_control.get_node('Container/Viewport').size.y = height
	p2_control.player_index = 1
	p2_control.mouse_device = Inf.p2_mouse
	p2_control.keyboard_device = Inf.p2_keyboard
	
	p2_control._reset_viewport()


func _on_enter():
	
	if not Inf.coop:
		get_node(from).queue_free()
		return
	
	
	yield(get_tree(), 'idle_frame')
	
	if get_node(from).has_node('Perspective') if has_node(from) else false:
		
		var p2_control = get_node(from).get_node('Perspective')
		
		if get_node(to).has_node('Perspective') if has_node(to) else false:
			
			var p1_control = get_node(to).get_node('Perspective')
			_split_viewports(p1_control, p2_control)


func _on_execute():
	
	pass#_on_enter()
