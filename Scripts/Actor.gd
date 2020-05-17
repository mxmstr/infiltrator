extends Spatial

export(String, MULTILINE) var tags

var tags_dict = {}

var player_index = 0 setget _set_player_index

signal entered_tree
signal player_index_changed


func _has_tag(tag):
	
	return tags_dict.has(tag)


func _get_tag(tag):
	
	return tags_dict[tag]


func _set_player_index(new_player_index):
	
	player_index = new_player_index
	
	emit_signal('player_index_changed', player_index)


func _enter_tree():
	
	for tag in tags.split(' '):
		
		var values = Array(tag.split(':'))
		var key = values.pop_front()
		
		tags_dict[key] = values
	
	
	for child in get_children():
		
		if child.get('make_unique') != null:
			
			Inf._make_unique(child)


func _ready():
	
	yield(get_tree(), 'idle_frame')
	
