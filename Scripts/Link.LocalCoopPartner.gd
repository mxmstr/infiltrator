extends 'res://Scripts/Link.gd'


func _split_viewports():
	
	var p1_control = to_node.get_node('Perspective')
	var p2_control = from_node.get_node('Perspective')
	
	var width = get_tree().root.size.x
	var height = get_tree().root.size.y / 2
	
	to_node.player_index = 0
	p1_control.get_node('Container').position.y = 0
	p1_control.get_node('Container').size.y = height
	p1_control.get_node('Container/SubViewport').size.x = width
	p1_control.get_node('Container/SubViewport').size.y = height
	p1_control.mouse_device = Meta.p1_mouse
	p1_control.keyboard_device = Meta.p1_keyboard
	
	from_node.player_index = 1
	p2_control.get_node('Container').position.y = height
	p2_control.get_node('Container').size.y = height
	p2_control.get_node('Container/SubViewport').size.x = width
	p2_control.get_node('Container/SubViewport').size.y = height
	p2_control.mouse_device = Meta.p2_mouse
	p2_control.keyboard_device = Meta.p2_keyboard


func _ready():
	
	if is_queued_for_deletion():
		return
	
	if not Meta.coop:
		
		if from_node != null:
			ActorServer.Destroy(from_node)
			
		return
	
	
	await get_tree().idle_frame
	
	if from_node.has_node('Perspective') and to_node.has_node('Perspective'):
		_split_viewports()
