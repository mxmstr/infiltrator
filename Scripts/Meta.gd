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
	Steer,
	Sidestep
}

enum Team {
	None,
	Red,
	Blue,
	Green,
	Yellow
}

var preloader
var tree_count = 0

var menu_input = false
var multi = false
var multi_points_to_win = 5
var multi_radar = true
var multi_outlines = false
var multi_loadout = ['Items/Beretta']
var coop = false
var player_count = 4
var player_data_default = {
	'mouse': -1,
	'keyboard': -1,
	'gamepad': -1,
	'character': 'Humans/Players/Anderson',
	'hp': 100.0,
	'team': Team.None,
	'auto_aim': true
	}
var player_data = [
	player_data_default.duplicate(),
	player_data_default.duplicate(),
	player_data_default.duplicate(),
	player_data_default.duplicate()
]
var rawinput = false

var cached_args = []

signal on_input


func _make_unique(old, new_owner=null):
	
	var export_props = {}
	
	for prop in old.get_property_list():
		if prop.usage == 8199:
			export_props[prop.name] = old.get(prop.name)
	
	
	var dir = Directory.new()
	var new_name = old.name
	var new_filename = 'res://duplicated' + str(tree_count) + '.tscn'
	
	
	prints('old', old.filename, old.tree_root.get_node('Start'))
	var new = load(old.filename)
	prints('new', new.instance().tree_root.get_node('Start'))
	ResourceSaver.save(new_filename, new)
	
	
	new = load(new_filename).instance()
	prints('new', new.filename, new.tree_root)
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
	old.free()
	
	
	dir.remove(new_filename)
	
	tree_count += 1


func _get_files_recursive(root, begins_with='', ends_with='', actor_tags=null):
	
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
			
			if file in ['.', '..']:
				continue
			
			if dir.current_is_dir():
				
				dirs.append('%s/%s' % [dir.get_current_dir(), file])
				continue
			
			if file.begins_with(begins_with) and (not ends_with.length() or file.ends_with(ends_with)):
				
				if actor_tags:
					
					if file.split('.')[0] != begins_with:
						continue
					
					var file_stripped = file.trim_prefix(begins_with).trim_suffix(ends_with)
					var file_tags = Array(file_stripped.split('.'))
					file_tags.erase('')
					
					
					var tag_count = 0
					
					for file_tag in file_tags:
						
						if file_tag == begins_with:
							continue
						
						if file_tag in actor_tags:
							tag_count += 1
					
					
					if file_to_add == null or tag_count > highest_tag_count:
						
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


func Evaluate(node, expression, arguments):
	
	var exec = Expression.new()
	if exec.parse(expression, arguments.keys()) > 0:
		prints(expression, exec.get_error_text())
	
	var result = exec.execute(arguments.values(), node)
	
	if exec.has_execute_failed():
		prints(expression, exec.get_error_text())
	
	return result


func PreloadActors():
	
	var actors = _get_files_recursive('res://Scenes/Actors/', '', '.tscn')
	
	for actor in actors:
		preloader.add_resource(actor, load(actor))


func PreloadLinks():
	
	var links = _get_files_recursive('res://Scenes/Links/', '', '.tscn')
	
	for link in links:
		preloader.add_resource(link, load(link))


func AddActor(actor_path, position=null, rotation=null, direction=null):
	
	var new_actor = preloader.get_resource('res://Scenes/Actors/' + actor_path + '.tscn').instance()
	$'/root/Mission/Actors'.add_child(new_actor)
	
	if position:
		new_actor.global_transform.origin = position
	
	if rotation:
		new_actor.rotation_degrees = rotation
	
	if direction:
		
		var target = new_actor.global_transform.origin - direction
		new_actor.look_at(target, Vector3(0, 1, 0))
	
	return new_actor


func AddLink(link_path):
	
	var new_link = preloader.get_resource('res://Scenes/Links/' + link_path + '.link.tscn').instance()
	$'/root/Mission/Links'.add_child(new_link)
	
	return new_link


func AddWayPoint(position):

	var waypoint = load('res://Scenes/Markers/Waypoint2.tscn').instance()
	$'/root/Mission/Actors'.add_child(waypoint)
	waypoint.global_transform.origin = position


func GetActorLinearVelocity(actor):
	
	return actor.get_node('Movement').velocity if actor.has_node('Movement') else Vector3()


func GetLinks(from, to, type, data={}):
	
	if from != null:
		data.from_node = from
	
	if to != null:
		data.to_node = to
	
	return LinkHub._get_links(type, data)


func CreateLink(from, to, type, data={}):
	
	if not from or not weakref(from).get_ref() or not to or not weakref(to).get_ref():
		return
	
	data.from = from.get_path()
	data.to = to.get_path()
	
	return LinkHub._create(type, data)


func DestroyLink(from, to, type, data={}):
	
	if from:
		data.from = from.get_path()
	
	if to:
		data.to = to.get_path()
	
	return LinkHub._destroy(type, data)


func StimulateActor(actor, stim, source=self, intensity=0.0, position=Vector3(), direction=Vector3()):
	
	if not weakref(actor).get_ref() or not weakref(source).get_ref():
		return
	
	if actor.has_node('Reception'):
		
		var data
		
		if source.get('tags') and source._has_tag('Shooter'):
			
			data = {
				'source': source,
				'shooter': source._get_tag('Shooter'),
				'position': position,
				'direction': direction,
				'intensity': intensity
				}
		
		else:
			
			data = {
				'source': source,
				'position': position,
				'direction': direction,
				'intensity': intensity
				}
		
		actor.get_node('Reception')._start_state(stim, data)


func CreateEvent(actor, event_name):
	
	var event = load('res://Scenes/Actors/Events' + event_name + '.tscn').instance()
	$'/root/Mission/Actors'.add_child(event)
	
	CreateLink(event, actor, 'EventMaster')


func _input(event):

	emit_signal('on_input', event)


func _enter_tree():
	
	for i in range(4):
		player_data[i].gamepad = i
	
	preloader = ResourcePreloader.new()
	
	PreloadActors()
	PreloadLinks()
	