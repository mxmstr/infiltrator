extends "res://Scripts/Action.gd"

onready var chamber = get_node_or_null('../Chamber')
onready var magazine = get_node_or_null('../Magazine')


func _on_action(state, data):
	
	._on_action(state, data)
	
	if state == 'FireProjectile':
		
		_play(animation)


func _ready():
	
	if tree.is_empty():
		return
	
	attributes[animation].speed = 1 / float(owner._get_tag('FireRate'))