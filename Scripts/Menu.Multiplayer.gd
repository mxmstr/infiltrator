extends MarginContainer

var characters = {
	'Mr. Anderson': {
		'scene': 'Humans/Anderson'
		},
	'Trinity': {
		'scene': 'Humans/Infiltrator'
		},
	'Agent': {
		'scene': 'Humans/Anderson2'
		},
	'Cop': {
		'scene': 'Humans/Anderson3'
		},
	'Karen': {
		'scene': 'Humans/Dawn'
		},
	'Max': {
		'scene': 'Humans/YoungMax'
		},
	'Scientist': {
		'scene': 'Humans/Scientist'
		},
	'SWAT': {
		'scene': 'Humans/Swat'
		}
	}


func _on_player_count_changed(value):
	
	Meta.player_count = value


func _on_character_selected(char_index, player_index, selector):
	
	Meta.player_data[player_index].character = characters[characters.keys()[selector.selected]].scene


func _ready():
	
	find_node('NumberOfPlayers').connect('value_changed', self, '_on_player_count_changed')
	
	
	var player_index = 0
	
	for child in Meta._get_children_recursive(self):
		
		if child.name == 'CharacterSelector':
			
			for charname in characters.keys():
				child.add_item(charname)
			
			child.connect('item_selected', self, '_on_character_selected', [player_index, child])
			child.emit_signal('item_selected', 0)
			
			player_index += 1
