extends AnimationTree

const directory = 'res://Scenes/Properties/Behaviors/'

export var interaction = 'Default'

var current_node

signal interaction_started
signal animation_changed
signal tree_update



func _set_behavior(new_behavior):
	
	pass
#	var path = directory + new_behavior + '.tscn'#owner.behaviors_root + owner.behaviors + '/' + new_behavior + '.tscn'
#	var behavior_source = load(path).instance()
#
#	for child in get_children():
#		child.name = child.name + '_'
#		child.queue_free()
#
#	for child in behavior_source.get_children():
#		var child_name = child.name
#		var new_child = child.duplicate()
#		add_child(new_child)
#		new_child.name = child_name
#
#	_start_interaction(behavior_source.interaction, true)
#
#	behavior_source.queue_free()


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
	
	pass
	#_start_interaction(get_node(interaction).resets_to)


func _start_interaction(_name, override=true):
	
	var playback = get('parameters/playback')
	var current = playback.get_current_node()
	
	playback.travel(_name)
	
#	if not _has_interaction(_name) or not get_node(_name)._can_start():
#		return
#
#	var next = get_node(_name)
#	var last = get_node(interaction) if has_node(interaction) else null
#	var has_priority = false
#
#	if override:
#		has_priority = true
#	else:
#		has_priority = next.priority == -1 or next.priority > last.priority
#
#	if has_priority:# and (next.dist == 0 or next.dist < next.distance_to):
#
#		if last != null:
#			last.exit()
#
#		if not next.animation in [null, 'Null']:
#			emit_signal('animation_changed', next.animation, next.blend, next.speed)
#
#		next.enter()
#		interaction = next.name
#
#		emit_signal('interaction_started', next)


func _init_transitions():
	
	var anim_names = []
	
	for idx in range(tree_root.get_transition_count()):
		
		var transition = tree_root.get_transition(idx)
		var anim_name = tree_root.get_transition_from(idx)
		
		if not anim_name in anim_names:
			var animation = tree_root.get_node(anim_name)
			
			if animation.has_method('init'):
				animation.init(anim_name, self)
			
			anim_names.append(anim_name)
		
		if transition.has_method('init'):
			transition.init(self)


#func _init_anim_nodes(node):
#
#	for idx in range(tree_root.get_transition_count()):
#
#		var node = tree_root.get_transition(idx)
#
#		if node.has_method('init'):
#			node.init(self)


func _ready():
	
	tree_root.set_start_node(interaction)
	
	_init_transitions()
	
	current_node = get('parameters/playback').get_current_node()
	
	anim_player = NodePath('AnimationPlayer')
	active = true


func _process(delta):
	
	var playback = get('parameters/playback')
	
	if current_node != playback.get_current_node():
		emit_signal('animation_changed', playback.get_current_node())
	
	current_node = playback.get_current_node()