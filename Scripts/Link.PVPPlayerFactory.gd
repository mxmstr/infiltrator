extends 'res://Scripts/Link.gd'


func _enter_tree():
	
	check_nulls = false


func _add_viewport(actor, data):
	
	var control = actor.get_node('Perspective')
	
	if Meta.player_count > 2:
		
#		var width = get_tree().root.size.x
#		var height = get_tree().root.size.y / 2
#
#		if actor.player_index in [0, 2]:
#			control.get_node('Container').rect_position.y = 0
#		else:
#			control.get_node('Container').rect_position.y = height
#
#		control.get_node('Container').rect_size.y = height
#		control.get_node('Container/Viewport').size.x = width
#		control.get_node('Container/Viewport').size.y = height
		
		var width = get_tree().root.size.x / 2
		var height = get_tree().root.size.y / 2

		if actor.player_index in [0, 2]:
			control.get_node('Container').rect_position.x = 0
		else:
			control.get_node('Container').rect_position.x = width

		if actor.player_index in [0, 1]:
			control.get_node('Container').rect_position.y = 0
		else:
			control.get_node('Container').rect_position.y = height

		control.get_node('Container').rect_size.y = height
		control.get_node('Container').rect_size.x = width
		control.get_node('Container/Viewport').size.x = width
		control.get_node('Container/Viewport').size.y = height
		
	else:
		
		var width = get_tree().root.size.x
		var height = get_tree().root.size.y / 2
		
		if actor.player_index == 0:
			control.get_node('Container').rect_position.y = 0
		else:
			control.get_node('Container').rect_position.y = height
		
		control.get_node('Container').rect_size.y = height
		control.get_node('Container/Viewport').size.x = width
		control.get_node('Container/Viewport').size.y = height

	#control.get_node('Container/Viewport').world = get_tree().root.world

	control.mouse_device = data.mouse
	control.keyboard_device = data.keyboard
	control.gamepad_device = data.gamepad


func _ready():
	
#	if is_queued_for_deletion():
#		return
#
#	if not Meta.multi:
#		return
	
	
	#yield(get_tree(), 'idle_frame')
	
	var spawn_links = Meta.GetLinks(self, null, 'PVPPlayerSpawn')
	spawn_links.shuffle()
	
	for i in range(Meta.player_count):
		
		var data = Meta.player_data[i]
		var marker = spawn_links[i].to_node
		
		var actor = Meta.AddActor(data.character, marker.global_transform.origin, marker.rotation_degrees)
		actor.player_index = i
		
		_add_viewport(actor, data)