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

enum DriverMode {
	Steer
	Sidestep
}

var tree_count = 0

var coop = false
var p1_mouse = -1
var p1_keyboard = -1
var p2_mouse = -1
var p2_keyboard = -1

var cached_args = []


func _make_unique(old, new_owner=null):
	
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
	
	
	old.get_parent().add_child_below_node(old, new)
	
	if new_owner:
		new.set_owner(new_owner)
	else:
		new.set_owner(old.owner)
	
	old.get_parent().remove_child(old)
	old.queue_free()
	
	
	dir.remove(new_filename)
	
	tree_count += 1


func _get_files_recursive(root, begins_with='', ends_with='', tags=null):
	
	var files = []
	var dirs = [root]
	
	var file_to_add
	var highest_tag_count = 0
	
	while not dirs.empty():
		
		var dir = Directory.new()
		dir.open(dirs.pop_front())
		dir.list_dir_begin()
		
		while true:
			
			var file = dir.get_next()
			
			if not file:
				
				dir.list_dir_end()
				break
			
			if dir.current_is_dir() and not file in ['.', '..']:
				
				dirs.append('%s/%s' % [dir.get_current_dir(), file])
				continue
			
			if file.begins_with(begins_with) and file.ends_with(ends_with):
				
				if tags:
					
					var file_tags = file.split('.')
					
					if file_tags[0] != begins_with:
						continue
					
					if file_to_add == null:
						file_to_add = '%s/%s' % [dir.get_current_dir(), file] 
						continue
					
					
					var tag_count = 0
					
					for tag in tags:
						if tag in file_tags:
							tag_count += 1
					
					if tag_count > highest_tag_count:
						
						file_to_add = '%s/%s' % [dir.get_current_dir(), file]
						highest_tag_count = tag_count
					
				else:
					
					files.append('%s/%s' % [dir.get_current_dir(), file])
	
	if file_to_add != null:
		files.append(file_to_add)
		
	return files


func _get_children_recursive(node, children=[]):
	
	for child in node.get_children():
		
		children.append(child)
		children = _get_children_recursive(child, children)
	
	return children


func AddActor(actor_path, position=Vector3(), rotation=Vector3()):
	
	var new_actor = load('res://Scenes/Actors/' + actor_path + '.tscn').instance()
	$'/root/Mission/Actors'.add_child(new_actor)
	
	new_actor.global_transform.origin = position
	new_actor.rotation_degrees = rotation
	
	return new_actor


func AddWayPoint(position):

	var waypoint = load('res://Scenes/Markers/Waypoint2.tscn').instance()
	$'/root/Mission/Actors'.add_child(waypoint)
	waypoint.global_transform.origin = position


func GetActorLinearVelocity(actor):
	
	return actor.get_node('Movement').velocity if actor.has_node('Movement') else Vector3()


func GetLinks(from, to, type, data={}):
	
	if from != null:
		data.from = from.get_path()
	
	if to != null:
		data.to = to.get_path()
	
	LinkHub._get_links(type, data)


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


func StimulateActor(actor, stim, source=self, intensity=0.0, position=Vector3(), direction=Vector3()):
	
	if actor.has_node('Perception'):
		
		var data = {
			'source': source,
			'position': position,
			'direction': direction,
			'intensity': intensity
			}
		
		actor.get_node('Perception')._start_state(stim, data)


func CreateEvent(actor, event_name):
	
	var event = load('res://Scenes/Actors/Events' + event_name + '.tscn').instance()
	$'/root/Mission/Actors'.add_child(event)
	
	CreateLink(event, actor, 'EventMaster')
