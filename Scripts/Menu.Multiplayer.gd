extends MarginContainer

const CONFIG_FILE = 'user://multiplayer.cfg'

var config

var characters = {
	'Mr. Anderson': {
		'scene': 'Humans/Players/Anderson'
		},
	'Trinity': {
		'scene': 'Humans/Players/Infiltrator'
		},
	'Agent': {
		'scene': 'Humans/Players/Agent'
		},
	'Cop': {
		'scene': 'Humans/Players/Cop'
		},
	'Karen': {
		'scene': 'Humans/Players/Dawn'
		},
	'Max': {
		'scene': 'Humans/Players/YoungMax'
		},
	'Scientist': {
		'scene': 'Humans/Players/Scientist'
		},
	'SWAT': {
		'scene': 'Humans/Players/Swat'
		}
	}

var weapons = {
	'Beretta': {
		'enabled': true,
		'scene': 'Items/Beretta'
	},
	'ColtCommando': {
		'enabled': false,
		'scene': 'Items/ColtCommando'
	},
	'DesertEagle': {
		'enabled': false,
		'scene': 'Items/DesertEagle'
	},
	'Ingram': {
		'enabled': false,
		'scene': 'Items/Ingram'
	},
	'Jackhammer': {
		'enabled': false,
		'scene': 'Items/Jackhammer'
	},
	'M79': {
		'enabled': false,
		'scene': 'Items/M79'
	},
	'MP5': {
		'enabled': false,
		'scene': 'Items/MP5'
	},
	'PumpShotgun': {
		'enabled': false,
		'scene': 'Items/PumpShotgun'
	},
	'SawedoffShotgun': {
		'enabled': false,
		'scene': 'Items/SawedoffShotgun'
	},
	'Sniper': {
		'enabled': false,
		'scene': 'Items/Sniper'
	}
}


func _load_config():
	
	config = ConfigFile.new()
	return config.load(CONFIG_FILE)


func _save_to_config(section, key, value):
	
	var config = ConfigFile.new()
	var err = config.load(CONFIG_FILE)
	
	if err:
		print('Error code when loading config file: ', err)
	else:
		config.set_value(section, key, value)
		config.save(CONFIG_FILE)


func _on_player_count_changed(value):
	
	Meta.player_count = value
	
	_save_to_config('Multiplayer', 'player_count', value)


func _on_max_points_changed(value):
	
	Meta.multi_points_to_win = value
	
	_save_to_config('Multiplayer', 'max_points', value)


func _on_radar_toggled(enabled):
	
	Meta.multi_radar = enabled
	
	_save_to_config('Multiplayer', 'radar', enabled)


func _on_outlines_toggled(enabled):
	
	Meta.multi_outlines = enabled
	
	_save_to_config('Multiplayer', 'outlines', enabled)


func _on_character_selected(char_index, player_index):
	
	var scene = characters[characters.keys()[char_index]].scene
	Meta.player_data[player_index].character = scene
	
	_save_to_config('Player' + str(player_index), 'character', char_index)


func _on_hp_changed(new_hp, player_index):
	
	Meta.player_data[player_index].hp = new_hp
	
	_save_to_config('Player' + str(player_index), 'hp', new_hp)


func _on_team_selected(team_index, player_index):
	
	Meta.player_data[player_index].team = team_index
	
	_save_to_config('Player' + str(player_index), 'team', team_index)


func _on_autoaim_toggled(enabled, player_index):
	
	Meta.player_data[player_index].auto_aim = enabled
	
	_save_to_config('Player' + str(player_index), 'autoaim', enabled)


func _on_weapon_toggled(enabled, weapon_name):
	
	weapons[weapon_name].enabled = enabled
	
	_save_to_config('Weapons', weapon_name, enabled)
	
	Meta.multi_loadout = []
	
	for weapon_name in weapons:
		if weapons[weapon_name].enabled:
			Meta.multi_loadout.append(weapons[weapon_name].scene)


func _ready():
	
	var error = _load_config()
	
	if error:
		config.save(CONFIG_FILE)
	
	
	var player_count = find_node('NumberOfPlayers')
	player_count.connect('value_changed', self, '_on_player_count_changed')
	player_count.value = config.get_value('Multiplayer', 'player_count', Meta.player_count) 
	_on_player_count_changed(player_count.value)
	
	
	var max_points = find_node('MaxPoints')
	max_points.connect('value_changed', self, '_on_max_points_changed')
	max_points.value = config.get_value('Multiplayer', 'max_points', Meta.multi_points_to_win)
	_on_max_points_changed(max_points.value)
	
	
	var radar = find_node('Radar').get_node('CheckBox')
	radar.connect('toggled', self, '_on_radar_toggled')
	radar.pressed = config.get_value('Multiplayer', 'radar', Meta.multi_radar)
	_on_radar_toggled(radar.pressed)
	
	
	var outlines = find_node('Outlines').get_node('CheckBox')
	outlines.connect('toggled', self, '_on_outlines_toggled')
	outlines.pressed = config.get_value('Multiplayer', 'outlines',  Meta.multi_outlines)
	_on_outlines_toggled(outlines.pressed)
	
	
	var player_index = 0
	
	for child in [find_node('Player1'), find_node('Player2'), find_node('Player3'), find_node('Player4')]:
		
		var character_selector = child.get_node('CharacterSelector/OptionButton')
		var hp_selector = child.get_node('HBoxContainer/HP')
		var team_selector = child.get_node('HBoxContainer/Team/OptionButton')
		var auto_aim_checkbox = child.get_node('HBoxContainer2/AutoAim/CheckBox')
		
		
		for charname in characters.keys():
			character_selector.add_item(charname)
		
		character_selector.connect('item_selected', self, '_on_character_selected', [player_index])
		character_selector.selected = config.get_value('Player' + str(player_index), 'character', 0)
		_on_character_selected(character_selector.selected, player_index)
		
		
		hp_selector.connect('value_changed', self, '_on_hp_changed', [player_index])
		hp_selector.value = config.get_value('Player' + str(player_index), 'hp', Meta.player_data_default.hp)
		_on_hp_changed(hp_selector.value, player_index)
		
		
		for team in Meta.Team.keys():
			team_selector.add_item(team)
		
		team_selector.connect('item_selected', self, '_on_team_selected', [player_index])
		team_selector.selected = config.get_value('Player' + str(player_index), 'team', Meta.player_data_default.team)
		_on_team_selected(team_selector.selected, player_index)
		
		
		auto_aim_checkbox.connect('toggled', self, '_on_autoaim_toggled', [player_index])
		auto_aim_checkbox.pressed = config.get_value('Player' + str(player_index), 'autoaim', Meta.player_data_default.auto_aim)
		_on_autoaim_toggled(auto_aim_checkbox.pressed, player_index)
		
		player_index += 1
	
	
	var weapons_grid = find_node('Weapons')
	
	for weapon_name in weapons:
		
		var checkbox = load('res://Scenes/UI/Menu.Checkbox.tscn').instance()
		weapons_grid.add_child(checkbox)
		
		checkbox.get_node('CheckBox').text = weapon_name
		checkbox.get_node('CheckBox').connect('toggled', self, '_on_weapon_toggled', [weapon_name])
		checkbox.get_node('CheckBox').pressed = config.get_value('Weapons', weapon_name, weapons[weapon_name].enabled)
		_on_weapon_toggled(checkbox.get_node('CheckBox').pressed, weapon_name)
		