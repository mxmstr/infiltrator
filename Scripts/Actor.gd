extends Spatial

export(NodePath) var new_owner
export(String, MULTILINE) var tags

var base_name
var tags_dict = {}
var player_index = 0 setget _set_player_index

signal entered_tree
signal integrate_forces
signal player_index_changed


func _has_tag(tag):
	
	return tags_dict.has(tag)


func _get_tag(tag):
	
	return tags_dict[tag]


func _set_player_index(new_player_index):
	
	player_index = new_player_index
	
	emit_signal('player_index_changed', player_index)


func _notification(what):
	
	if what == NOTIFICATION_INSTANCED:
		
		base_name = name


func _enter_tree():
	
	#.replace('\n', ' ')
	for tag in tags.split(' '):
		
		var values = Array(tag.split(':'))
		var key = values.pop_front()
		
		tags_dict[key] = values
	
	
	for child in get_children():
		
		if new_owner:
			child.set_owner(get_node(new_owner))

#		if child.get('make_unique') != null:
#
#			if new_owner.is_empty():
#				Meta._make_unique(child)
#			else:
#				Meta._make_unique(child, get_node(new_owner))


func _get_meta():
	
	return Meta


func _evaluate(expression, arguments):
	
	var exec = Expression.new()
	exec.parse(expression, arguments.keys())
	var result = exec.execute(arguments.values(), self)
	
	if exec.has_execute_failed():
		prints(exec.get_error_text())
	
	return result


func _ready():
	
	yield(get_tree(), 'idle_frame')
	
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
