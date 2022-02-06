extends 'res://Scripts/Link.gd'

export(String) var container

var root
var container_node
var human = false
var restore_collisions = true
var merge = false
var from_behavior
var movement
var collision
var reception
var item_position_offset
var item_rotation_offset

onready var actors = $'/root/Mission/Actors'


func _is_container(node):
	
	if node.get_script() != null:
		
		var script_name = node.get_script().get_path().get_file()
		return script_name == 'Prop.Container.gd'
	
	return false


func _try_container(prop):
	
	if prop._is_full():
		return false
	
	for item_tag in prop.required_tags_dict.keys():
		if item_tag.length() and not item_tag in to_node.tags_dict.keys():
			return false
	
	return true


func _find_free_container():
	
	for prop in from_node.get_children():
		
		if _is_container(prop) and _try_container(prop):
			
			container = prop.name
			container_node = prop
			
			return true
	
	return false


func _get_item_position_offset(item):
	
	if item._has_tag('Offset-position'):

		var item_data = item._get_tag('Offset-position')
		
		var root_parent_name = item_data[0]
		var item_bone_name = item_data[1]
		var item_offset = item_data[2].split(',')

		return Vector3(float(item_offset[0]), float(item_offset[1]), float(item_offset[2])) if (
			#(root_parent_name == '' or (container_node.root and container_node.root.get_parent().name == root_parent_name)) and \
			(item_bone_name == '' or (container_node.root and item_bone_name == container_node.root.bone_name))
			) else Vector3()
	
	return Vector3()


func _get_item_rotation_offset(item):
	
	if item._has_tag('Offset-rotation'):

		var item_data = item._get_tag('Offset-rotation')

		var root_parent_name = item_data[0]
		var item_bone_name = item_data[1]
		var item_offset = item_data[2].split(',')

		return Vector3(deg2rad(float(item_offset[0])), deg2rad(float(item_offset[1])), deg2rad(float(item_offset[2]))) if (
			#(root_parent_name == '' or (container_node.root and container_node.root.get_parent().name == root_parent_name)) and \
			(item_bone_name == '' or (container_node.root and item_bone_name == container_node.root.bone_name))
			) else Vector3()
	
	return Vector3()


func _move_item():
	
	return
	
	if is_queued_for_deletion() or _is_invalid():
		return
	
	if movement and is_instance_valid(movement) and not movement.is_queued_for_deletion():
		
		var new_transform = root.global_transform
		
		if movement.has_method('_teleport'):
			movement._teleport(new_transform.origin, new_transform.basis)


func _ready():
	
	if is_queued_for_deletion():
		return
	
	from_behavior = from_node.get_node_or_null('Behavior')
	movement = to_node.get_node_or_null('Movement')
	collision = to_node.get_node_or_null('Collision')
	reception = to_node.get_node_or_null('Reception')
	
	if container == '' or container == null:
		
		if not _find_free_container():
			queue_free()
			return
		
	else:
		
		if _try_container(from_node.get_node(container)):
			
			if to_node.is_queued_for_deletion():
				_destroy()
				return
			
			container_node = from_node.get_node(container)
			
		else:
			queue_free()
			return
	
	_disable_collision()
	
	yield(get_tree(), 'idle_frame')
	
	item_position_offset = _get_item_position_offset(to_node)
	item_rotation_offset = _get_item_rotation_offset(to_node)
	
	to_node.get_parent().remove_child(to_node)
	container_node.root.add_child(to_node)
	to_node.translation = item_position_offset
	to_node.rotation = item_rotation_offset
	
#	root = Spatial.new()
#	container_node.root.add_child(root)
#	root.translation = item_position_offset
#	root.rotation = item_rotation_offset
	
	
#	to_node.get_parent().call_deferred('remove_child', to_node)
#	root.call_deferred('add_child', to_node)
#	to_node.call_deferred('set_translation', Vector3())
#	to_node.call_deferred('set_rotation', Vector3())


func _process(delta):
	
	if is_queued_for_deletion() or _is_invalid():
		return
	
	if not container_node._has_item(to_node):
		queue_free()
	
#	if not human:
#		_move_item()


func _disable_collision():
	
	to_node.visible = not container_node.invisible
	
	if collision:
		collision.disabled = true
	
	if to_node is Area:
		to_node.monitoring = false
	
	if to_node is RigidBody:
		to_node.sleeping = true
	
	container_node._add_item(to_node)
	
	if to_node._has_tag('AttachBone'):
		container_node.root.bone_name = to_node._get_tag('AttachBone')
	else:
		container_node.root.bone_name = container_node.bone_name
	
	if from_behavior.get_script().has_script_signal('pre_advance'):
		
		from_behavior.connect('pre_advance', self, '_move_item')
		human = true


func _restore_collision():
	
	if is_instance_valid(to_node):
	
		to_node.visible = true
		
		if container_node and is_instance_valid(container_node):
			container_node._apply_launch_attributes(to_node)
		
		if collision:
			collision.disabled = false
		
		if to_node is Area:
			to_node.monitoring = true
		
		if to_node is RigidBody:
			to_node.sleeping = false


func _destroy():
	
	if container_node and is_instance_valid(container_node):
		
		container_node._remove_item(to_node)
		
		if is_instance_valid(to_node) and to_node._has_tag('AttachBone'):
			container_node.root.bone_name = container_node.bone_name
	
	if restore_collisions:
		_restore_collision()
	
	if root and is_instance_valid(root):
		root.queue_free()
	
	if is_instance_valid(to_node):
		
		var to_node_transform = to_node.global_transform
		
		container_node.root.remove_child(to_node)
		actors.add_child(to_node)
		
		if movement:
			movement._teleport(to_node_transform.origin, to_node_transform.basis)
	
	._destroy()
