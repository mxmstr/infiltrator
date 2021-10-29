extends "res://Scripts/Action.gd"

const item_names = ['Beretta', 'Colt', 'DesertEagle', 'Ingram', 'Jackhammer', 'M79', 'MP5', 'PumpShotgun', 'SawedoffShotgun', 'Sniper']

var animations = {}

onready var behavior = get_node_or_null('../Behavior')
onready var righthand = get_node_or_null('../RightHandContainer')
onready var camera_raycast = get_node_or_null('../CameraRig/Camera')
onready var camera_raycast_target = get_node_or_null('../CameraRaycastStim/Target')


func _load_ammo():
	
	righthand.items[0].get_node('Magazine')._transfer_items_from(owner)


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
			
			if animations.has(item_name):
				
				_play(animations[item_name][0])
	