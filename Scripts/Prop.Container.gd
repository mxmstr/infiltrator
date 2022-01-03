extends Node

export(NodePath) var path
export(String) var bone_name
export var factory_mode = false
export var parent_position = true
export var parent_rotation = true
export(Vector3) var position_offset
export(Vector3) var rotation_degrees_offset
export(float) var release_speed
export(Vector3) var release_direction
export(Vector2) var release_angular_spread = Vector2(0, 0)
export(float) var release_lifetime
export var release_exclude_parent = false
export var release_exclude_parent_lifetime = 0.0
export(int) var max_quantity
export(bool) var invisible
export(bool) var interactable
export(String, MULTILINE) var required_tags

var movement
var root
var shooter
var required_tags_dict = {}
var items = [] setget _set_items, _get_items

signal item_added
signal item_removed
signal item_released
signal released


func _set_items(new_items):
	
	items = new_items


func _get_items():
	
	for item in items.duplicate():
		if not item is String and not is_instance_valid(item):
			items.erase(item)
	
	return items


func _is_empty():
	
	return items.size() == 0


func _is_full():
	
	return max_quantity > 0 and items.size() >= max_quantity


func _add_item(item):
	
	if max_quantity > 0 and items.size() >= max_quantity:
		return false
	
	if factory_mode:
		
		if not item is String:
		
			item.queue_free()
			item = item.system_path
	
	items.append(item)
	
	emit_signal('item_added', self, item)
	
	return true


func _remove_item(item):
	
	if _has_item(item):
		
		items.erase(item)
		
		emit_signal('item_removed', self, item)
		
		return item


func _remove_all_items():
	
	var returned = items.duplicate()
	items = []
	
	return returned


func _has_item(item):
	
	return items.has(item)


func _has_item_with_tag(tag):
	
	for item in items:
		if is_instance_valid(item) and  item._has_tag(tag):
			return true
	
	return false


func _has_item_with_tags(tags):
	
	for item in items:
		
		if not is_instance_valid(item):
			continue
		
		var tagged = true
		
		for tag in tags:
			if not item._has_tag(tag):
				tagged = false
		
		if not tagged:
			continue
		
		return true
	
	return false


func _get_item_with_tags(tags):
	
	for item in items:
		
		var tagged = true
		
		for tag in tags:
			if not item._has_tag(tag):
				tagged = false
		
		if tagged:
			return item
	
	return null


func _is_container(node):
	
	if node.get_script() != null:
		
		var script_name = node.get_script().get_path().get_file()
		return script_name == 'Prop.Container.gd'
	
	return false


func _can_transfer_items_from(from):
	
	for prop in from.get_children():
		
		if _is_container(prop):
			
			if prop._is_empty():
				continue
			
#			prints(prop, prop.items.size())
			var valid = true
			
			for required_tag in required_tags_dict.keys():
				
				if not required_tag in prop.required_tags_dict.keys():
					
					valid = false
					break
			
			if valid:
				return true
	
	return false


func _transfer_items_from(from, limit=0):
	
	var from_container
	var best_tag_count = 0
	
	for prop in from.get_children():
		
		if _is_container(prop):
			
			var tag_count = 0
			
			for required_tag in required_tags_dict.keys():
				if required_tag in prop.required_tags_dict.keys():
					tag_count += 1
			
			if tag_count > best_tag_count:
				
				from_container = prop
				best_tag_count = tag_count
	
	
	if from_container:
		
		if factory_mode:
			
			var count = 0
			
			while not _is_full() and from_container.items.size():
				
				var item = from_container._release_front()
				
				_add_item(item)
				
				count += 1
				
				if limit > 0 and count == limit:
					break
			
			return from_container.items.size()
	
	return 0


func _push_front_into_container(new_container):
	
	if not items.size():
		return
	
	var item = _release_front()
	
	Meta.CreateLink(owner, item, 'Contains', {'container': new_container})


func _exclude_recursive(item, parent):
	
	var parent_list = []
	
	if item is PhysicsBody:
		
		item.add_collision_exception_with(parent)
		
		if parent.has_node('Hitboxes'):
			for hitbox in parent.get_node('Hitboxes').get_children():
				item.add_collision_exception_with(hitbox)
	
	if item is Area:
		
		item.get_node('Movement').collision_exceptions.append(parent)
		
		if parent.has_node('Hitboxes'):
			for hitbox in parent.get_node('Hitboxes').get_children():
				item.get_node('Movement').collision_exceptions.append(hitbox)
	
	
	parent_list.append(parent)
	shooter = parent
	
	for link in Meta.GetLinks(null, parent, 'Contains'):
		parent_list += _exclude_recursive(item, link.from_node)
	
	return parent_list


func _remove_exclusions(item, parent_list):
	
	if not is_instance_valid(item):
		return
	
	for parent in parent_list:
		
		if item is PhysicsBody:
			
			item.remove_collision_exception_with(parent)
			
			if parent.has_node('Hitboxes'):
				for hitbox in parent.get_node('Hitboxes').get_children():
					item.remove_collision_exception_with(hitbox)
		
		if item is Area:
			
			item.get_node('Movement').collision_exceptions.erase(parent)
			
			if parent.has_node('Hitboxes'):
				for hitbox in parent.get_node('Hitboxes').get_children():
					item.get_node('Movement').collision_exceptions.erase(hitbox)


func _apply_launch_attributes(item):
	
	var item_movement = item.get_node_or_null('Movement')
	
	if item_movement:
		
		item_movement._set_direction(release_direction, true)
		item_movement._set_speed(release_speed)
		
		if release_angular_spread.length():
			
			var spread_x = release_angular_spread.x
			item_movement.angular_direction.x = rand_range(-spread_x, spread_x)

			var spread_y = release_angular_spread.y
			item_movement.angular_direction.y = rand_range(-spread_y, spread_y)
	
	
	if release_exclude_parent:
		
		var parent_list = _exclude_recursive(item, owner)
		
		if shooter._has_tag('Shooter'):
			shooter = shooter._get_tag('Shooter')
		
		if release_exclude_parent_lifetime > 0:
			get_tree().create_timer(release_exclude_parent_lifetime).connect('timeout', self, '_remove_exclusions', [item, parent_list])
	
	
	if release_lifetime > 0:
		get_tree().create_timer(release_lifetime).connect('timeout', item, 'queue_free')


func _create_and_launch_item(item_path, rotation=null):
	
	var item = Meta.AddActor(item_path, null, null, null, { 'Shooter': shooter })
	var position = root.global_transform.origin
	var basis = root.global_transform.basis
	
	if rotation:
		basis = Basis(rotation)
	
	item.get_node('Movement')._teleport(position, basis)
	
	_apply_launch_attributes(item)
	
	emit_signal('item_released', item)
	
	return item


func _release_front_threaded():
	
	var thread = Thread.new()
	thread.start(self, '_release_front')
	
	Meta.threads.append(thread)


func _release_front(release_speed_override=null):
	
	if not items.size():
		return
	
	var release_speed_default = release_speed
	
	if release_speed_override:
		release_speed = release_speed_override
	
	var item
	
	if factory_mode:
		
		item = Meta.AddActor(_remove_item(items[0]), root.global_transform.origin, root.rotation)
		_apply_launch_attributes(item)
	
	else:
		
		item = items[0]
		Meta.DestroyLink(owner, item, 'Contains', {'container': name})
	
	if is_instance_valid(item):
		item._set_tag('Shooter', shooter)
	
	emit_signal('item_released', item)
	
	release_speed = release_speed_default
	
	return item


func _release(item):
	
	if not items.size():
		return
	
	Meta.DestroyLink(owner, item, 'Contains', {'container': name})
	
	if is_instance_valid(item):
		item._set_tag('Shooter', shooter)
	
	emit_signal('item_released', item)
	
	return item


func _release_all():
	
	var released = []
	
	if factory_mode:
		
		for item in items:
			released.append(Meta.AddActor(_remove_item(item), root.global_transform.origin, root.rotation))
			_apply_launch_attributes(item)
	
	else:
		
		released = Meta.DestroyLink(owner, null, 'Contains', {'container': name})
		
		for item in released.duplicate():
			if not is_instance_valid(item):
				released.erase(item)
	
	for item in released:
		
		item._set_tag('Shooter', shooter)
		emit_signal('item_released', item)
	
	return released


func _delete_all():
	
	if factory_mode:
		
		items.clear()
	
	else:
		
		var removed = items.duplicate()
		
		Meta.DestroyLink(owner, null, 'Contains', {'container': name})
		
		for item in removed:
			item.queue_free()


func _reset_root():
	
	root.translation = position_offset
	root.rotation_degrees = rotation_degrees_offset


func _ready():
	
	movement = get_node_or_null('../Movement')
	shooter = owner
	
	
	for tag in required_tags.split(' '):
		
		var values = Array(tag.split(':'))
		var key = values.pop_front()
		
		required_tags_dict[key] = values
	
	
	if path.is_empty():
		
		root = self
		
	else:
	
		root = BoneAttachment.new()
		root.name = name + 'Root'
		get_node(path).call_deferred('add_child', root)
		
		if bone_name != '':
			root.bone_name = bone_name
		
		_reset_root()


#func _process(delta):
#
#	for item in items.duplicate():
#		if not item is String and not is_instance_valid(item):
#			items.erase(item)
