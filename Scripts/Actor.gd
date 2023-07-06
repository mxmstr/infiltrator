extends Node3D

@export var new_owner: NodePath
@export_multiline var tags = ''

var base_name
var system_path
var tags_dict = {}
var player_index = 0 : set = _set_player_index
var input_context = 'Default'

signal entered_tree
signal integrate_forces
signal player_index_changed
signal on_input
signal ressurected


func _has_tag(tag):
	
	return tags_dict.has(tag)


func _has_tags(_tags):
	
	return tags_dict.has_all(_tags)


func _get_tag(tag):
	
	return tags_dict[tag]


func _get_tags(_tag):
	
	var matching = []
	
	for tag in tags_dict:
		if _tag in tag:
			matching.append(tags_dict[tag])
	
	return matching


func _set_tag(tag, value):
	
	tags_dict[tag] = value


func _set_player_index(new_player_index):
	
	player_index = new_player_index
	
	emit_signal('player_index_changed', player_index)


func _parse_tags():
	
	for tag in tags.split(' '):
		
		var values = Array(tag.split(':'))
		var key = values.pop_front()
		
		if values.size() == 1:
			tags_dict[key] = values[0]
		else:
			tags_dict[key] = values


func _notification(what):
	
	if what == NOTIFICATION_SCENE_INSTANTIATED:
		
		base_name = name
		system_path = scene_file_path.replace('.tscn', '').replace('res://Scenes/Actors/', '')
		
		_parse_tags()


func _enter_tree():
	
	#if tags_dict.is_empty():
	_parse_tags()
	
	for child in get_children():
		
		if new_owner:
			child.set_owner(get_node(new_owner))

#		if child.get('make_unique') != null:
#
#			if new_owner.is_empty():
#				Meta._make_unique(child)
#			else:
#				Meta._make_unique(child, get_node(new_owner))


func _evaluate(expression, arguments):
	
#	if 'Pistol' == name:
#		prints(expression)
	
	var exec = Expression.new()
	if exec.parse(expression, arguments.keys()) > 0:
		prints(expression, exec.get_error_text())
	
	var result = exec.execute(arguments.values(), self)
	
	if exec.has_execute_failed():
		prints(expression, exec.get_error_text())
	
	return result


func _ready():
	
#	set_process_input(false)
	
#	await get_tree().idle_frame
	
#	set_physics_process_internal(false)
#	set_process_internal(false)
#	set_physics_process(false)
#	set_process(false)
	
	for child in get_children():
		
		pass
#		child.set_physics_process_internal(false)
#		child.set_process_internal(false)
#		child.set_physics_process(false)
#		child.set_process(false)


func _integrate_forces(state):

	emit_signal('integrate_forces', state)


#func _process(delta):
#
#	if has_node('Particles'):
#		if not get_node('Particles').visible:
#			prints('asdf')
