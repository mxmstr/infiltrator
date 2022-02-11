extends "res://Scripts/Action.gd"

onready var reception = get_node_or_null('../Reception')
onready var chamber = get_node_or_null('../Chamber')
onready var magazine = get_node_or_null('../Magazine')


func _fire_effect(effect_path):
	
	prints(effect_path)
	Meta.AddActor(effect_path, owner.translation, owner.rotation)


func _clone_and_shoot():
	
	if chamber._is_empty():
		return
	
	var item = chamber.items[0]
	var item_clone = chamber._create_and_launch_item(item.system_path)
#	var item_clone = item.duplicate()
#	actors.add_child(item_clone)
#	item_clone.transform.origin = item.transform.origin
#	item_clone.transform.basis = item.transform.basis
#	chamber._apply_launch_attributes(item_clone)
#	item_clone._set_tag('Shooter', item._get_tag('Shooter'))
	prints('clone', chamber.root)


func _shoot_array_threaded(count):
	
	var item = chamber._release_front()
	
	for i in range(count):
		
		var thread = Thread.new()
		thread.start(self, '_shoot_array', [item.system_path])
		
		Meta.threads.append(thread)


func _shoot_array(count):
	
#	var system_path = userdata[0]
	var item = chamber._release_front()
#
#	_clone_and_shoot(item, count - 1)
	
	for i in range(count):
		
		var item_clone = chamber._create_and_launch_item(item.system_path)


func _state_start():
	
	reception._reflect('UseReact')


func _ready():
	
	if tree.is_empty():
		return
	
	attributes[animation_list[0]].speed = float(owner._get_tag('FireRate'))
