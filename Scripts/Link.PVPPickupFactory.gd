extends 'res://Scripts/Link.gd'

var spawn_chance = 1.0#0.8
var spawn_count = 8
var respawn_time = 15.0
var pickups = []


func _on_timeout():
	
	randomize()
	var markers = get_children()
	markers.shuffle()
	
	_refresh_spawn(markers[0])
	markers[0].get_node('RespawnSound').playing = true


func _on_stimulate(item):
	
	pickups.erase(item)
	get_tree().create_timer(respawn_time).connect('timeout', self, '_on_timeout')


func _on_factory_finished(link, marker):
	
	var offset = Vector3()
	
	for output in link.outputs:
		
		output.translation = marker.translation + offset
		output.rotation = marker.rotation
		
		offset += Vector3(0, 0.5, 0)
	
	for output in link.outputs:
		
		if output.has_node('AreaStim'):
			
			pickups.append(output)
			output.get_node('AreaStim').connect(
				'stimulate',
				self,
				'_on_stimulate',
				[output],
				CONNECT_ONESHOT
				)
			
			break


func _refresh_spawn(marker):
	
	var weapon_path = Meta.multi_loadout[randi() % Meta.multi_loadout.size()]
	var node_name = Meta.preloader.get_resource('res://Scenes/Actors/' + weapon_path + '.tscn').instance().name
	
	for file in Meta._get_files_recursive('res://Scenes/Links/Factories/', 'Factory', '.link.tscn', [node_name]):
		
		var new_link = Meta.preloader.get_resource(file).instance()
		$'/root/Mission/Links'.add_child(new_link)
		
		new_link.connect('finished', self, '_on_factory_finished', [new_link, marker])


func _enter_tree():
	
	check_nulls = false


func _ready():
	
	yield(get_tree(), 'idle_frame')
	
	if get_child_count() == 0:
		return
	
	randomize()
	var markers = get_children()
	markers.shuffle()
	
	spawn_count = int(markers.size())
	
	for i in range(spawn_count):
		_refresh_spawn(markers[i])
#
#	pickup_idx = randi() % get_child_count()

#	get_tree().create_timer(respawn_time).connect('timeout', self, '_on_timeout')
