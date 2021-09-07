extends 'res://Scripts/AnimationTree.gd'

var enable_abilities = true

var target
var last_node


func _start_state(_name, _data={}):

#	prints(owner.name, _name)
	
	if not enable_abilities:
		return
	
#	if get('parameters/playback').get_travel_path().size():
#		print('asdf')
#		return
	
#	data = _data
#
#	if tree_root.has_method('_start'):
#		tree_root._start(_name)
	
	._start_state(_name, data)


func _stop_travel():
	
	if tree_root.has_method('_start'):
		tree_root._start( get('parameters/playback').get_current_node())


func _get_visible_interactions():
	
	var interactions = []
	
	for node in tree_root.nodes:
		if node.has_method('_is_visible') and node._is_visible():# and tree_root.can_travel(node.node_name):
			interactions.append(node.node_name)
	
	return interactions


func _has_interaction(_name):
	
	return false#has_node(_name)


func _set_skeleton():
	
	if not has_node('../Model'):
		return
	
	
	var skeleton = $'../Model'.get_child(0)
	$AnimationPlayer.root_node = $AnimationPlayer.get_path_to(skeleton)


func _ready():
	
	_set_skeleton()


func _process(delta):
	
	var playback = get('parameters/playback')
	var current_node = playback.get_current_node()
	
#	if 'Pistol' in owner.name and current_node != last_node:
#		prints(OS.get_system_time_msecs(), current_node, playback.get_travel_path())
#		last_node = current_node
