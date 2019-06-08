extends Node

export(String) var interaction

""" Signal is pre-connected in Actor.Static prefab """
signal interaction_started
signal animation_changed



func _set_behavior(new_behavior):
	
	var path = owner.behaviors_root + owner.behaviors + '/' + new_behavior + '.tscn'
	var behavior_source = load(path).instance()
	
	for child in get_children():
		child.name = child.name + '_'
		child.queue_free()
	
	for child in behavior_source.get_children():
		var child_name = child.name
		var new_child = child.duplicate()
		add_child(new_child)
		new_child.name = child_name
	
	_start_interaction(behavior_source.interaction, true)
	
	behavior_source.queue_free()


func _get_visible_interactions():
	
	var interactions = []
	
	#var dist = sender.global_transform.origin.distance_to(owner.global_transform.origin)
	
	for child in get_children():
		if child.is_visible(): #and (child.dist == 0 or child.dist > dist):
			interactions.append(child.name)
	
	return interactions


func _has_interaction(_name):
	
	return has_node(_name)


func _reset_interaction():
	
	_start_interaction(get_node(interaction).resets_to)


func _start_interaction(_name, override=true):
	
	if not _has_interaction(_name) or not get_node(_name)._can_start():
		return
	
	var next = get_node(_name)
	var has_priority = false
	
	if override:
		has_priority = true
	else:
		var last = get_node(interaction)
		has_priority = next.priority == -1 or next.priority > last.priority
		
		if has_priority:
			last.exit()
	
	
	if has_priority:# and (next.dist == 0 or next.dist < next.distance_to):
		
		if not next.animation in [null, 'Null']:
			emit_signal('animation_changed', next.animation, next.blend, next.speed)
		
		next.enter()
		interaction = next.name
		
		emit_signal('interaction_started', next)


func _ready():
	
	pass#get_node(interaction).enter()