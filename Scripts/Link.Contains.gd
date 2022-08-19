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


func _equals(other):
	
	return base_name == other.base_name and to_node == other.to_node


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


static func _get_item_position_offset(item, _container_node):
	
	for item_data in item._get_tags('Offset-position'):
		
		var root_parent_name = item_data[0]
		var item_bone_name = item_data[1]
		var item_offset = item_data[2].split(',')

		if (#(root_parent_name == '' or (container_node.root and container_node.root.get_parent().name == root_parent_name)) and \
			(item_bone_name == '' or (_container_node.root and item_bone_name == _container_node.root.bone_name))
			):
			return Vector3(float(item_offset[0]), float(item_offset[1]), float(item_offset[2]))
	
	return Vector3()


static func _get_item_rotation_offset(item, _container_node):
	
	for item_data in item._get_tags('Offset-rotation'):
		
		var root_parent_name = item_data[0]
		var item_bone_name = item_data[1]
		var item_offset = item_data[2].split(',')
		
		if (#(root_parent_name == '' or (container_node.root and container_node.root.get_parent().name == root_parent_name)) and \
			(item_bone_name == '' or (_container_node.root and item_bone_name == _container_node.root.bone_name))
			):
			return Vector3(deg2rad(float(item_offset[0])), deg2rad(float(item_offset[1])), deg2rad(float(item_offset[2]))) 
	
	return Vector3()


func _ready():
	
	if _is_invalid():
		return
	
	from_behavior = from_node.get_node_or_null('Behavior')
	
	if to_node is Node:
		
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
	
	if _is_invalid():
		return
	
	_deactivate_actor()
	
	yield(get_tree(), 'idle_frame')
	
	if _is_invalid():
		return
	
	_reparent()


func _process(delta):
	
	if is_queued_for_deletion() or _is_invalid():
		return
	
	if not container_node._has_item(to_node):
		queue_free()


func _deactivate_actor():
	
	to_node.visible = not container_node.invisible
	
	ActorServer.DisableCollision(to_node)
	
	if to_node is Area:
		
		to_node.monitoring = false
	
	if to_node is RigidBody:
		
		to_node.sleeping = true
		to_node.mode = RigidBody.MODE_STATIC
	
	if to_node is Node:
		
		if to_node._has_tag('AttachBone'):
			container_node.root.bone_name = to_node._get_tag('AttachBone')
		else:
			container_node.root.bone_name = container_node.bone_name
	
	container_node._add_item(to_node)


func _reparent():
	
	if to_node is Projectile:
		return
	
	item_position_offset = _get_item_position_offset(to_node, container_node)
	item_rotation_offset = _get_item_rotation_offset(to_node, container_node)
	
	to_node.get_parent().remove_child(to_node)
	container_node.root.add_child(to_node)
	to_node.translation = item_position_offset
	to_node.rotation = item_rotation_offset
	to_node.scale = Vector3(1, 1, 1)


func _activate_actor():
	
	to_node.visible = true
	
	if container_node and is_instance_valid(container_node):
		container_node._apply_launch_attributes(to_node)
	
	if collision:
		collision.call_deferred('set_disabled', false)
	
	if to_node is Area:
		to_node.monitoring = true
	
	if to_node is RigidBody:
		to_node.sleeping = false
		to_node.mode = RigidBody.MODE_RIGID


func _destroy():
	
	if container_node and is_instance_valid(container_node):
		
		container_node._remove_item(to_node)
		
		if is_instance_valid(to_node) and to_node is Node and to_node._has_tag('AttachBone'):
			container_node.root.bone_name = container_node.bone_name
	
	if root and is_instance_valid(root):
		root.queue_free()
	
	if is_instance_valid(to_node):
	
		if to_node is Node:
			
			var to_node_transform = to_node.global_transform
			
			to_node.get_parent().remove_child(to_node)
			actors.add_child(to_node)
			
			if movement:
				movement._teleport(to_node_transform.origin, to_node_transform.basis)
		
		if restore_collisions:
			_activate_actor()
	
	._destroy()


func _physics_process(delta):
	
	if is_instance_valid(to_node) and is_instance_valid(container_node) and to_node is Projectile:
		
		to_node.transform = container_node.global_transform
