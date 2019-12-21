extends Node

onready var list = find_node('ListContainer')
onready var hint = find_node('Hint')


func _on_coop_toggled(pressed):
	
	Inf.coop = pressed


func _ready():
	
	var files = []
	var dir = Directory.new()
	dir.open('res://Scenes/')
	dir.list_dir_begin()
	
	while true:
		
		var file = dir.get_next()
		
		if file == '':
			break
			
		elif file.ends_with('.tscn'):
			
			var item = load('res://Scenes/UI/Menu.Scenes.Item.tscn').instance()
			item.name = file.replace('.tres', '')
			list.add_child(item)
			
			var button = item.get_node('Button')
			button.text = file.replace('.tres', '')
			button.connect('pressed', get_tree(), 'change_scene', ['res://Scenes/' + file])
	
	
	var coop = list.get_node('Coop/CheckBox')
	coop.connect('toggled', self, '_on_coop_toggled')
	