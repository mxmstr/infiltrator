extends Node

export(String) var interaction

signal animation_changed



func set_behavior(new_behavior):
	
	print(new_behavior)
#	for child in get_children():
#		child.queue_free()
#
#
#	var behavior_source = load(behavior_path).instance()
#	var behavior = behavior_source.get_node('Behavior')
#
#	for child in behavior.get_children():
#		add_child(child.duplicate())
#
#	behavior_source.queue_free()


func get_visible_interactions(sender):
	
	var interactions = []
	
	var dist = sender.global_transform.origin.distance_to(owner.global_transform.origin)
	
	for child in get_children():
		if child.is_visible() \
			and (child.dist == 0 or child.dist > dist):
			interactions.append(child.name)
	
	return interactions


func start_interaction(_name):
	
	var next = get_node(_name)
	var last = get_node(interaction)
	
	if next != null and next.priority > last.priority:
		
		last.exit()
		
		if next.animation != null:
			emit_signal('animation_changed', next.animation)
		
		next.enter()
		interaction = next.name


func _ready():
	
	get_node(interaction).enter()
