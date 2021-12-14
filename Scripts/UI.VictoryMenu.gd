extends Control

var pvp
var rank_names = ['1st', '2nd', '3rd', '4th']

onready var message = find_node('VictoryMessage')
onready var rank = find_node('Rank')
onready var kills = find_node('Kills')
onready var deaths = find_node('Deaths')


func _on_player_died(player_index, points):
	
	if player_index == owner.owner.player_index:
	
		deaths.text = 'Deaths: ' + str(points)


func _on_player_scored(player_index, points):
	
	if player_index == owner.owner.player_index:
		
		kills.text = 'Kills: ' + str(points)


func _on_player_won(winner_name, scores):
	
	message.text = winner_name + ' wins!'
	
	var player_index = owner.owner.player_index
	var rank_idx = 0
	
	for score in scores:
		if scores[player_index] < score:
			rank_idx += 1
	
	rank.text = 'Rank: ' + rank_names[rank_idx]


func _on_team_scored(team_index, points):
	
	if team_index == int(owner.owner._get_tag('Team')):
		
		kills.text = 'Kills: ' + str(points)


func _on_team_won(winner_name, scores):
	
	message.text = winner_name + ' wins!'
	
	var team_index = int(owner.owner._get_tag('Team'))
	var rank_idx = 0
	
	for score in scores:
		if scores[team_index] < score:
			rank_idx += 1
	
	rank.text = 'Rank: ' + rank_names[rank_idx]


func _ready():
	
	yield(get_tree(), 'idle_frame')
	
	
	pvp = get_node_or_null('/root/Mission/Links/PVPPlayerFactory')
	
	if not pvp:
		return
	
	pvp.connect('player_died', self, '_on_player_died')
	pvp.connect('player_scored', self, '_on_player_scored')
	pvp.connect('player_won', self, '_on_player_won')
	pvp.connect('team_scored', self, '_on_team_scored')
	pvp.connect('team_won', self, '_on_team_won')
	
	var exit = find_node('Exit').get_node('Button')
	
	exit.connect('pressed', get_tree(), 'change_scene', ['res://Scenes/MainMenu.tscn'])
