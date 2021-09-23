extends 'res://Scripts/Link.gd'

var player_points = [0, 0, 0, 0]
var player_deaths = [0, 0, 0, 0]
var team_points = [0, 0, 0, 0, 0]
var spawn_links


func _on_player_died(player):
	
	player_deaths[player.player_index] += 1
	
	var behavior = player.get_node('Behavior')
	
	if behavior.data.has('shooter'):
		
		var shooter = behavior.data.shooter
		var team = int(shooter._get_tag('Team'))
		
		if team > 0:
			
			team_points[team] += 1
			
			if team_points[team] >= Meta.multi_points_to_win:
				pass
			
		else:
			
			player_points[shooter.player_index] += 1
			
			if player_points[shooter.player_index] >= Meta.multi_points_to_win:
				pass


func _play_music():
	
	var animation_list = Array($AnimationPlayer.get_animation_list())
	randomize()
	animation_list.shuffle()
	
	$AnimationPlayer.play(animation_list[0])
#	$Music.play()


func _respawn(actor):
	
	spawn_links.shuffle()
	var data = Meta.player_data[actor.player_index]
	var marker = spawn_links[0].to_node
	
	actor.global_transform.origin = marker.global_transform.origin
	actor.rotation = marker.rotation
	actor.get_node('Stamina').hp = data.hp
	actor.get_node('Behavior')._teleport_to_state('Start')


func _enter_tree():
	
	check_nulls = false


func _add_viewport(actor, data):
	
	var perspective = actor.get_node('Perspective')
	
	if Meta.player_count > 2:
		
		var width = get_tree().root.size.x / 2
		var height = get_tree().root.size.y / 2

		if actor.player_index in [0, 2]:
			perspective.rect_position.x = 0
		else:
			perspective.rect_position.x = width

		if actor.player_index in [0, 1]:
			perspective.rect_position.y = 0
		else:
			perspective.rect_position.y = height

		perspective.rect_size.y = height
		perspective.rect_size.x = width
		perspective.get_node('Viewport').size.x = width
		perspective.get_node('Viewport').size.y = height
		
	else:
		
		var width = get_tree().root.size.x
		var height = get_tree().root.size.y / 2
		
		if actor.player_index == 0:
			perspective.rect_position.y = 0
		else:
			perspective.rect_position.y = height
		
		perspective.rect_size.y = height
		perspective.get_node('Viewport').size.x = width
		perspective.get_node('Viewport').size.y = height

	#control.get_node('Container/Viewport').world = get_tree().root.world

	perspective.mouse_device = data.mouse
	perspective.keyboard_device = data.keyboard
	perspective.gamepad_device = data.gamepad


func _ready():
	
#	if is_queued_for_deletion():
#		return
#
#	if not Meta.multi:
#		return
	
	
	#yield(get_tree(), 'idle_frame')
	
	
	spawn_links = Meta.GetLinks(self, null, 'PVPPlayerSpawn')
	spawn_links.shuffle()
	
	var actors = []
	
	for i in range(Meta.player_count):
		
		var data = Meta.player_data[i]
		var marker = spawn_links[i].to_node
		
		var actor = Meta.AddActor(data.character, marker.global_transform.origin, marker.rotation_degrees)
		actor.player_index = i
		actor.get_node('Stamina').hp = data.hp
		actor._set_tag('Team', str(data.team))
		
		_add_viewport(actor, data)
		
		actors.append(actor)
	
	
	_play_music()
	
	
	yield(get_tree(), 'idle_frame')
	
	for i in range(Meta.player_count):
		
		var data = Meta.player_data[i]
		
#		actors[i].get_node('Stamina').connect('just_died', self, '_on_player_died', [actors[i]])
		actors[i].get_node('Behavior').tree_root.get_node('Die').connect('playing', self, '_on_player_died', [actors[i]])
	
	