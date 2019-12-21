extends Node

enum Visibility {
	INVISIBLE,
	PHYSICAL, 
	REMOTE
}

enum Blend {
	ACTION,
	MOVEMENT,
	LAYERED
}

enum Priority {
	LOW,
	HIGH,
	VERY_HIGH
}

var tree_count = 0

var coop = false
var p1_mouse = -1
var p1_keyboard = -1
var p2_mouse = -1
var p2_keyboard = -1


func _make_unique(old):
	
	var export_props = {}
	
	for prop in old.get_property_list():
		if prop.usage == 8199:
			export_props[prop.name] = old.get(prop.name)
	
	
	var dir = Directory.new()
	var new_name = old.name
	var new_filename = 'res://duplicated' + str(tree_count) + '.tscn'
	
	
	var new = load(old.filename)
	ResourceSaver.save(new_filename, new)
	
	
	new = load(new_filename).instance()
	new.name = old.name
	new.set_meta('unique', true)
	old.name += '_'
	
	
	for prop in export_props:
		new.set(prop, export_props[prop])
	
	
	old.get_parent().call_deferred('add_child_below_node', old, new)
	new.call_deferred('set_owner', old.owner)
	old.get_parent().call_deferred('remove_child', old)
	old.queue_free()
	
	
	dir.remove(new_filename)
	
	tree_count += 1