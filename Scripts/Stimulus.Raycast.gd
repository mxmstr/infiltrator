extends RayCast

export(String) var stim_type
export var auto = true
export var continuous = false
export var send_to_self = false

export(NodePath) var path
export(String) var bone_name
export(String, MULTILINE) var required_tags

var root
var selection

signal selection_changed
signal triggered


func _has_selection():
	
	if get_collider() == null or get_collider().get('tags') == null:
		return false
	
	for item_tag in required_tags.split(' '):
		if not get_collider()._has_tag(item_tag):
			return false
	
	return true


func _stimulate(stim_type_override=''):
	
	var new_stim = stim_type_override if stim_type_override != '' else stim_type
	
	if new_stim == '' or selection == null:
		return
	
	
	var data
	
	if send_to_self:
		Meta.StimulateActor(owner, new_stim, owner, $'../Movement'.velocity.length() * -1, get_collision_point(), get_collision_normal() * -1)
	else:
		Meta.StimulateActor(get_collider(), new_stim, owner, $'../Movement'.velocity.length(), get_collision_point(), get_collision_normal())
	
	
	emit_signal('triggered', data)


func _update_raycast_selection():
	
	selection = get_collider() if _has_selection() else null
	
	emit_signal('selection_changed', selection)


func _ready():
	
	root = BoneAttachment.new()
	get_node(path).call_deferred('add_child', root)
	
	if bone_name != '':
		root.bone_name = bone_name
	
	#add_exception(owner)


func _process(delta):
	
	global_transform.origin = root.global_transform.origin
	global_transform.basis = root.global_transform.basis
	
	_update_raycast_selection()
	
	if auto:
		_stimulate()
