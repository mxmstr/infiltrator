extends MarginContainer


func _ready():
	
	var resume = find_node('Resume').get_node('Button')
	var exit = find_node('Exit').get_node('Button')
	
	resume.connect('pressed', owner.get_node('../HUDMode'), '_start_state', ['Default'])
	exit.connect('pressed', get_tree(), 'change_scene', ['res://Scenes/MainMenu.tscn'])
