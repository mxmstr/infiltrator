extends "res://Scripts/Action.gd"

export(String) var shoot_schema
export(String) var shoot_idle_schema

var shoot_animation_list = []
var shoot_idle_animation_list = []

onready var righthand = get_node_or_null('../RightHandContainer')


func _ready():
	
	if tree.is_empty():
		return
	
	shoot_animation_list = _load_animations(shoot_schema)
	shoot_idle_animation_list = _load_animations(shoot_idle_schema)


func _on_action(state, data):
	
	if state == 'UseReact':
		
		if righthand._has_item_with_tag('Firearm'):
			
			_set_animation(shoot_animation_list[0])
			_set_animation(shoot_animation_list[1], -1)
			_set_animation(shoot_animation_list[1], 1)
			_start_action()


func _process(delta):
	
	pass
	#get_node(RIGHTHAND)._has_item_with_tag(TAG)
#	elif state == 'IdleAim':
#
#		_play(idle_animation_list[0])