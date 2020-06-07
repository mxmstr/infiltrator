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
	
	
#	old.get_parent().call_deferred('add_child_below_node', old, new)
#	new.call_deferred('set_owner', old.owner)
#	old.get_parent().call_deferred('remove_child', old)
#	old.queue_free()

	old.get_parent().add_child_below_node(old, new)
	new.set_owner(old.owner)
	old.get_parent().remove_child(old)
	old.queue_free()
	
	
	dir.remove(new_filename)
	
	tree_count += 1


func _get_children_recursive(node, children=[]):
	
	for child in node.get_children():
		
		children.append(child)
		children = _get_children_recursive(child, children)
	
	return children


func _add_actor(actor_path, position=Vector3(), rotation=Vector3()):
	
	var new_actor = load('res://Scenes/Actors/' + actor_path + '.tscn').instance()
	$'/root/Mission/Actors'.add_child(new_actor)
	
	new_actor.global_transform.origin = position
	new_actor.rotation_degrees = rotation
	
	return new_actor


func _add_waypoint(position):

	var waypoint = load('res://Scenes/Markers/Waypoint2.tscn').instance()
	$'/root/Mission/Actors'.add_child(waypoint)
	waypoint.global_transform.origin = position


func GetActorLinearVelocity(actor):
	
	return actor.get_node('Movement').velocity if actor.has_node('Movement') else Vector3()


func CreateLink(from, to, type, data={}):
	
	data.from = from.get_path()
	data.to = to.get_path()
	
	LinkHub._create(type, data)


func DestroyLink(from, to, type, data={}):
	
	if from != null:
		data.from = from.get_path()
	
	if to != null:
		data.to = to.get_path()
	
	LinkHub._destroy(type, data)


func StimulateActor(actor, stim, collider, position=Vector3(), direction=Vector3(), intensity=0.0):
	
	if actor.has_node('Receptor'):
		
		var data = {
			'collider': collider,
			'position': position,
			'direction': direction,
			'intensity': intensity
			}
		
		actor.get_node('Receptor')._start_state(stim, data)