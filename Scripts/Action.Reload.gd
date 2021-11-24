extends "res://Scripts/Action.gd"

const item_names = ['Beretta', 'Colt', 'DesertEagle', 'Ingram', 'Jackhammer', 'M79', 'MP5', 'PumpShotgun', 'SawedoffShotgun', 'Sniper']

var animations = {}

onready var behavior = get_node_or_null('../Behavior')
onready var righthand = get_node_or_null('../RightHandContainer')
onready var camera_raycast = get_node_or_null('../CameraRig/Camera')
onready var camera_raycast_target = get_node_or_null('../CameraRaycastStim/Target')


func _play_reload_sound():
	
	righthand.items[0].get_node('Audio')._start_state('Reload')


func _load_magazine():
	
	righthand.items[0].get_node('Magazine')._transfer_items_from(owner)


func _load_shotgun_shell():
	
	var item = righthand.items[0]
	var remaining = item.get_node('Magazine')._transfer_items_from(owner, 1)
	var is_full = item.get_node('Magazine')._is_full()
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
			
#			if righthand._has_item_with_tag('Shotgun'):
#
#
#			else:
			
			var item_name = righthand.items[0].base_name
			
			if animations.has(item_name) and righthand.items[0].get_node('Magazine')._can_transfer_items_from(owner):
				
				_play(animations[item_name][0])
	
