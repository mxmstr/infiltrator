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
export var release_exclude_parent = false
export(int) var max_quantity
export(bool) var invisible
export(bool) var interactable
export(String, MULTILINE) var required_tags

var root
var required_tags_dict = {}
var items = []

signal item_added
signal item_removed
signal released


func _is_empty():
	
	return len(items) == 0


func _is_full():
	
	return items.size() >= max_quantity


func _add_item(item):
	
	if max_quantity > 0 and items.size() >= max_quantity:
		return false
	
	if factory_mode and not item is String:
		
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


func _push_front_into_container(new_container):
	
	if not items.size():
		return
	
	var item = _release_front()
	
	Meta.CreateLink(owner, item, 'Contains', {'container': new_container})


func _exclude_recursive(item, parent):
	
	item.add_collision_exception_with(parent)
	
	if parent.has_node('Hitboxes'):
		for hitbox in parent.get_node('Hitboxes').get_children():
			item.add_collision_exception_with(hitbox)
	
	
	for link in Meta.GetLinks(null, parent, 'Contains'):
		_exclude_recursive(item, link.from_node)


func _release_front():
	
	if not items.size():
		return
	
	var item = items[0]
	
	if factory_mode:
		items.pop_front()
		return Meta.AddActor(item, root.global_transform.origin, root.rotation_degrees)
	
	Meta.DestroyLink(owner, item, 'Contains', {'container': name})
	
	return item


func _release_all():
	
	Meta.DestroyLink(owner, null, 'Contains', {'container': name})


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