extends RayCast

export(String) var stim_type
export var auto = true
export var continuous = false
export var send_to_self = false

export var predict_collision = false
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
		
		if item_tag.length() and not get_collider()._has_tag(item_tag):
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
		Meta.StimulateActor(selection, new_stim, owner, $'../Movement'.velocity.length(), get_collision_point(), get_collision_normal())
	
	
	emit_signal('triggered', data)


func _update_raycast_selection():
	
	$Target.global_transform.origin = get_collision_point()
	
	if _has_selection():
		
		selection = get_collider()
	
	emit_signal('selection_changed', selection)


func _reset_root():
	
	root.translation = Vector3()
	root.rotation_degrees = Vector3()


func _on_before_move(velocity):
	
	if velocity.length() > 0:#cast_to.length():
		
		var origin = owner.global_transform.origin
		var next_origin = owner.global_transform.translated(velocity).origin
		var temp_raycast = duplicate()

		owner.add_child(temp_raycast)
		temp_raycast.cast_to = Vector3(0, 0, -origin.distance_to(next_origin))
		temp_raycast.force_raycast_update()

		if temp_raycast.get_collider():
			#print('asdf')
			Meta.StimulateActor(temp_raycast.get_collider(), stim_type, owner, velocity.length(), temp_raycast.get_collision_point(), temp_raycast.get_collision_normal())
		
		temp_raycast.free()


func _ready():
	
	if not path.is_empty():
		
		root = BoneAttachment.new()
		get_node(path).call_deferred('add_child', root)
		
		if bone_name != '':
			root.bone_name = bone_name
		
		_reset_root()
	
	
	if predict_collision:
		get_node('../Movement').connect('before_move', self, '_on_before_move')


func _process(delta):
	
	if has_node('../Reception') and not get_node('../Reception').active:
		return
	
	if root:
		
		global_transform.origin = root.global_transform.origin
		global_transform.basis = root.global_transform.basis
	
#	elif predict_collision:
#
#		var velocity = get_node('../Movement').velocity
#
#		if velocity.length() > 0:# cast_to.length():
#
#			var origin = owner.global_transform.origin
#			var next_origin = owner.global_transform.translated(velocity).origin
#			var temp_raycast = duplicate()
#
#			owner.add_child(temp_raycast)
#			temp_raycast.cast_to = Vector3(0, 0, -origin.distance_to(next_origin))
#			temp_raycast.force_raycast_update()
#
##			add_child(temp_raycast)
##			temp_raycast.collide_with_areas = true
##			temp_raycast.collision_mask = collision_mask
##			temp_raycast.global_transform.origin = origin
##
##			#temp_raycast.look_at(next_origin, Vector3(0, 1, 0))
##			temp_raycast.cast_to = Vector3(0, 0, -origin.distance_to(next_origin))
##			temp_raycast.force_raycast_update()
#
#			if temp_raycast.get_collider():
#				print('asdf')
#				Meta.StimulateActor(temp_raycast.get_collider(), stim_type, owner, velocity.length(), temp_raycast.get_collision_point(), temp_raycast.get_collision_normal())
#
#			temp_raycast.free()
	
	_update_raycast_selection()
	
	if auto:
		_stimulate()
