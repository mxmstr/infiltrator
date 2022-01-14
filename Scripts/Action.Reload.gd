extends "res://Scripts/Action.gd"

const item_names = ['Beretta', 'Colt', 'DesertEagle', 'Ingram', 'Jackhammer', 'M79', 'MP5', 'PumpShotgun', 'SawedoffShotgun', 'Sniper']

var animations = {}

onready var behavior = get_node_or_null('../Behavior')
onready var righthand = get_node_or_null('../RightHandContainer')
onready var camera_raycast = get_node_or_null('../CameraRig/Camera')
onready var camera_raycast_target = get_node_or_null('../CameraRaycastStim/Target')


func _play_reload_sound():
	
	if righthand._is_empty():
		return
	
	righthand.items[0].get_node('Audio')._start_state('Reload')


func _is_container(node):
	
	if node.get_script() != null:
		
		var script_name = node.get_script().get_path().get_file()
		return script_name == 'Prop.Container.gd'
	
	return false


func _can_transfer_items_to(to):
	
	for prop in owner.get_children():
		
		if _is_container(prop):
			
			if prop._is_empty():
				continue
			
			var valid = true
			
			for required_tag in to.required_tags_dict.keys():
				
				if not required_tag in prop.required_tags_dict.keys():
					
					valid = false
					break
			
			if valid:
				return true
	
	return false


func _transfer_items_to(to, limit=0):
	
	var from_container
	var best_tag_count = 0
	
	for prop in owner.get_children():
		
		if _is_container(prop):
			
			var tag_count = 0
			
			for required_tag in to.required_tags_dict.keys():
				if required_tag in prop.required_tags_dict.keys():
					tag_count += 1
			
			if tag_count > best_tag_count:
				
				from_container = prop
				best_tag_count = tag_count
	
	
	if from_container:
		
		if to.factory_mode:
			
			var count = 0
			
			while not to._is_full() and from_container.items.size():
				
				var item = from_container._release_front()
				
				to._add_item(item)
				
				count += 1
				
				if limit > 0 and count == limit:
					break
			
			return from_container.items.size()
	
	return 0


func _load_magazine():
	
	if righthand._is_empty():
		return
	
	if not righthand.items[0].has_node('Magazine'):
		return
	
	var magazine = righthand.items[0].get_node('Magazine')
	var chamber = righthand.items[0].get_node('Chamber')
	var limit = 0 if chamber._is_empty() else max(magazine.max_quantity - 1, 0)
	
	_transfer_items_to(magazine, limit)


func _load_shotgun_shell():
	
	var item = righthand.items[0]
	var magazine = righthand.items[0].get_node('Magazine')
	
	var remaining = _transfer_items_to(magazine, 1)
	var is_full = magazine._is_full()
	var item_name = item.base_name
	
	if animations.has(item_name) and not is_full and remaining > 0:
		_play(animations[item_name][0])


func _ready():
	
	if tree.is_empty():
		return
	
	for item_name in item_names:
		animations[item_name] = _load_animations('Reload' + item_name)


func _on_action(_state, data):
	
	new_state = _state
	
	if new_state == state:
		
		if righthand._has_item_with_tag('Firearm'):
			
			var item_name = righthand.items[0].base_name
			var chamber = righthand.items[0].get_node('Chamber')
			var magazine = righthand.items[0].get_node('Magazine')
			var is_full = magazine.max_quantity <= magazine.items.size() + (0 if chamber._is_empty() else 1)
			
			if animations.has(item_name) and not is_full and _can_transfer_items_to(magazine):
				_play(animations[item_name][0])
	
