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
export(Vector2) var release_angular_spread
export var release_exclude_parent = false
export(int) var max_quantity
export(bool) var invisible
export(bool) var interactable
export(String, MULTILINE) var required_tags

var root
var shooter
var required_tags_dict = {}
var items = []

signal item_added
signal item_removed
signal released


func _is_empty():
	
	return len(items) == 0


func _is_full():
	
	return max_quantity > 0 and items.size() >= max_quantity


func _add_item(item):
	
	if max_quantity > 0 and items.size() >= max_quantity:
		return false
	
	if factory_mode:
		
		if not item is String:
		
			item.queue_free()
			item = item.system_path
	
	if release_exclude_parent:
		_exclude_recursive(item, owner)
	
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
		if item._has_tag(tag):
			return true
	
	return false


func _has_item_with_tags(tags):
	
	for item in items:
		
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


func _transfer_items_to(to):
	
	if factory_mode and items.size():
		
		var dummy = Meta.AddActor(items[0])
		var link = Meta.CreateLink(to, dummy, 'Contains')
		var container_node = link.container_node
		
		if container_node:
			
			link._destroy()
			
			while items.size() and not container_node._is_full():
				
				container_node._add_item(items.pop_front())
		
		dummy.queue_free()
	
	else:
	
		for item in _release_all():
			
			if Meta.CreateLink(to, item, 'Contains').is_queued_for_deletion():
				item.queue_free()


func _is_container(node):
	
	if node.get_script() != null:
		
		var script_name = node.get_script().get_path().get_file()
		return script_name == 'Prop.Container.gd'
	
	return false


func _can_transfer_items_from(from):
	
	for prop in from.get_children():
		
		if _is_container(prop):
			
			var valid = true
			
			for required_tag in required_tags_dict.keys():
				
				if not required_tag in prop.required_tags_dict.keys():
					
					valid = false
					break
			
			if valid:
				return true
	
	return false


func _transfer_items_from(from):
	
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
			
			while not _is_full() and from_container.items.size():
				
				var item = from_container.items.pop_front()
				
				_add_item(item)


func _push_front_into_container(new_container):
	
	if not items.size():
		return
	
	var item = _release_front()
	
	Meta.CreateLink(owner, item, 'Contains', {'container': new_container})


func _exclude_recursive(item, parent):
	
	item.add_collision_exception_with(parent)
	shooter = parent
	
	if parent.has_node('Hitboxes'):
		for hitbox in parent.get_node('Hitboxes').get_children():
			item.add_collision_exception_with(hitbox)
	
	
	for link in Meta.GetLinks(null, parent, 'Contains'):
		_exclude_recursive(item, link.from_node)


func _release_front():
	
	if not items.size():
		return
	
	var item
	
	if factory_mode:
		
		item = Meta.AddActor(items.pop_front(), root.global_transform.origin, root.rotation_degrees)
	
	else:
		
		item = items[0]
		Meta.DestroyLink(owner, item, 'Contains', {'container': name})
	
	item._set_tag('Shooter', shooter)
	
	return item


func _release(item):
	
	if not items.size():
		return
	
	Meta.DestroyLink(owner, item, 'Contains', {'container': name})
	
	item._set_tag('Shooter', owner)
	
	return item


func _release_all():
	
	if factory_mode:
		
		var released = []
		
		for item in items:
			released.append(Meta.AddActor(item, root.global_transform.origin, root.rotation_degrees))
		
		return released
	
	else:
		
		return Meta.DestroyLink(owner, null, 'Contains', {'container': name})


func _delete_all():
	
	if factory_mode:
		
		items.clear()
	
	else:
		
		for item in items:
			
			Meta.DestroyLink(owner, null, 'Contains', {'container': name})
			item.queue_free()


func _pool_items(item_tags_string, dont_clone=false):
	
	if _is_empty():
		return
	
	var item_tags = item_tags_string.split(' ')
	var items_grouped = {}
	
	for item in items:

		var tagged = true

		for item_tag in item_tags:
			if not item_tag in item.tags_dict.keys():
				tagged = false
				break

		if not tagged:
			continue
		
		if 'Firearm' in item_tags:
			
			for firearm_item in Meta.DestroyLink(item, null, 'Contains', { 'container': 'Chamber' }):
				
				var magazine = item.get_node('Magazine')
				
				if magazine._is_empty():
					firearm_item.queue_free()
					continue
				
				if Meta.CreateLink(magazine.items[0], firearm_item, 'Contains', { 'container': '' }).is_queued_for_deletion():
					pass
#					print('Noooooooooooooooooooooo')
#				else:
#					print('Yaaaaaaaaaaaaaaaaaaaaa')
			
			
			var right_hand = get_node_or_null('../RightHandContainer')
			
			if right_hand and not right_hand._is_empty() and right_hand.items[0].system_path == item.system_path:
				
				for firearm_item in Meta.DestroyLink(item, null, 'Contains', { 'container': 'Magazine' }):
					Meta.CreateLink(owner, firearm_item, 'Contains', { 'container': '' })
				
				item.queue_free()
				
				continue
		
		
		
		if not items_grouped.has(item.system_path):
			items_grouped[item.system_path] = [item]
		else:
			items_grouped[item.system_path].append(item)
	
	
	for group in items_grouped.keys():
		
		if items_grouped[group].size() < 2:
			continue
		
		var item_clones = [Meta.AddActor(group)]
		
		for item in items_grouped[group]:
			
			for prop in item.get_children():
				
				if prop.get_script() and prop.get_script().get_path().get_file() == 'Prop.Container.gd':
					
					for removed_item in prop._remove_all_items():
						
						if not item_clones[0].get_node(prop.name)._add_item(removed_item):
							
							item_clones.push_front(Meta.AddActor(group))
							item_clones[0].get_node(prop.name)._add_item(removed_item)
			
			Meta.DestroyLink(owner, item, 'Contains')
		
		for clone in item_clones:
			Meta.CreateLink(owner, clone, 'Contains', { 'container': '' }).is_queued_for_deletion()
		
#	var item_tags = item_tags_string.split(' ')
#
#	for item in items:
#
#		var tagged = true
#
#		for item_tag in item_tags:
#			if not item_tag in item.tags_dict.keys():
#				tagged = false
#				break
#
#		if not tagged:
#			continue
#
#		prints('pooled', item.name)
#		Meta.DestroyLink(null, item, 'Contains')
#
#		var contained = false
#
#		for other in items:
#
#			if item == other:
#				continue
#
#			if not Meta.CreateLink(other, item, 'Contains', { 'container': '' }).is_queued_for_deletion():
#				contained = true
#				break
#
#		prints('pooled2', item.name, contained)
#		if not contained and fallback_actor_path:
#
#			var fallback = Meta.AddActor(fallback_actor_path)
#			print(Meta.CreateLink(fallback, item, 'Contains', { 'container': '' }).container)
#			print(Meta.CreateLink(owner, fallback, 'Contains', { 'container': '' }).container)


func _reset_root():
	
	root.translation = position_offset
	root.rotation_degrees = rotation_degrees_offset


func _ready():
	
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