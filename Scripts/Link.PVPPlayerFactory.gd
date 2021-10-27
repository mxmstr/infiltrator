extends 'res://Scripts/Link.gd'

var player_points = [0, 0, 0, 0]
var player_deaths = [0, 0, 0, 0]
var team_points = [0, 0, 0, 0, 0]
var actors = []
var markers = []

signal player_died
signal player_scored
signal player_won
signal team_scored
signal team_won


func _on_player_died(player):
	
	player_deaths[player.player_index] += 1
	emit_signal('player_died', player.player_index, player_deaths[player.player_index])
	
	
	var behavior = player.get_node('Behavior')
	
	if behavior.data.has('shooter'):
		
		var shooter = behavior.data.shooter
		var shooter_team = int(shooter._get_tag('Team'))
		var player_team = int(player._get_tag('Team'))
		
		if shooter_team > 0 and shooter_team != player_team:
			
			team_points[shooter_team] += 1
			emit_signal('team_scored', shooter_team, team_points[shooter_team])
			
			if team_points[shooter_team] >= Meta.multi_points_to_win:
				
				emit_signal('team_won', Meta.Team.keys()[shooter_team], team_points)
				
				_suspend_players()
				_play_victory_music()
			
		else:
			
			player_points[shooter.player_index] += 1
			emit_signal('player_scored', shooter.player_index, player_points[shooter.player_index])
			
			if player_points[shooter.player_index] >= Meta.multi_points_to_win:
				
				emit_signal('player_won', shooter.name, player_points)
				
				_suspend_players()
				_play_victory_music()


func _play_fight_music():
	
	var animation_list = Array($FightMusic.get_animation_list())
	randomize()
	animation_list.shuffle()
	
	$FightMusic.play(animation_list[0])


func _play_victory_music():
	
	$FightMusic.stop()
	$VictoryMusic.play($VictoryMusic.get_animation_list()[0])


func _suspend_players():
	
	for actor in actors:
		
		actor.get_node('HUDMode')._teleport_to_state('Victory')


func _respawn(actor):
	
	var marker_idx = randi() % markers.size()
	var marker = markers[marker_idx]
	var data = Meta.player_data[actor.player_index]
	
	actor.global_transform.origin = marker.global_transform.origin
	actor.rotation = marker.rotation
	actor.get_node('Stamina').hp = data.hp
	actor.get_node('Behavior')._start_state('Default')#_teleport_to_state('Start')


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
	
	if is_queued_for_deletion():
		return
#
#	if not Meta.multi:
#		return
	
	
	#yield(get_tree(), 'idle_frame')
	
	for child in get_children():
		if 'RespawnMarker' in child.name:
			markers.append(child)
	
	
	for i in range(Meta.player_count):
		
		var data = Meta.player_data[i]
		var marker = markers[i]
		
		var actor = Meta.AddActor(data.character, marker.global_transform.origin, marker.rotation_degrees)
		actor.player_index = i
		actor.get_node('Stamina').hp = data.hp
		actor.get_node('WeaponTargetLock').auto_aim = data.auto_aim
		actor._set_tag('Team', str(data.team))
		
		_add_viewport(actor, data)
		
		actors.append(actor)
	
	
	_play_fight_music()
	
	
	yield(get_tree(), 'idle_frame')
	
	for i in range(Meta.player_count):
		
		var data = Meta.player_data[i]
		
#		actors[i].get_node('Stamina').connect('just_died', self, '_on_player_died', [actors[i]])
		
		if actors[i].get_node('Behavior').tree_root.has_node('Die'):
			var die_node = actors[i].get_node('Behavior').tree_root.get_node('Die')
			die_node.connect('playing', self, '_on_player_died', [actors[i]])
	
	