extends "res://Scripts/Action.gd"

onready var actors = get_node_or_null('/root/Mission/Actors')
onready var reception = get_node_or_null('../Reception')
onready var chamber = get_node_or_null('../Chamber')
onready var magazine = get_node_or_null('../Magazine')


func _clone_and_shoot(item, i):

	if i == 0:
		return
	
#	var item_clone = chamber._create_and_launch_item(item.system_path)#item.duplicate()
#
#	item_clone.rotation = item.rotation
#	item_clone.translation = item.translation
	var item_clone = item.duplicate()
	item_clone._set_tag('Shooter', item._get_tag('Shooter'))
	actors.add_child(item_clone)
	chamber._apply_launch_attributes(item_clone)
	
	call_deferred('_clone_and_shoot', item, i - 1)


func _shoot_array(count):
	
	var item = chamber._release_front()
	
	call_deferred('_clone_and_shoot', item, count - 1)


func _on_action(_state, data): 
	
	new_state = _state
	
	if new_state == state:
		
		if _play(animation_list[0]):
			
			reception._reflect('UseReact')


func _ready():
	
	if tree.is_empty():
		return
	
	attributes[animation_list[0]].speed = float(owner._get_tag('FireRate'))
