extends Spatial

export(String, MULTILINE) var tags

var tags_dict = {}

signal entered_tree


func _has_tag(tag):
	
	return tags_dict.has(tag)


func _get_tag(tag):
	
	return tags_dict[tag]


func _enter_tree():
	
	for tag in tags.split(' '):
		
		var values = Array(tag.split(':'))
		var key = values.pop_front()
		
		tags_dict[key] = values
	
	
	for child in get_children():
		
		if child.get('make_unique') != null:
			
			Inf._make_unique(child)
