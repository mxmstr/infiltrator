extends 'res://Scripts/Link.gd'

var pickup_idx = 0


func _on_timeout():
	
	_refresh_spawn(get_child(pickup_idx))
	
	pickup_idx += 1
	
	if pickup_idx >= get_child_count():
		pickup_idx = 0


func _on_factory_finished(link, marker):
	
	link.outputs[0].translation = marker.translation
	link.outputs[0].rotation = marker.rotation


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
	
	for marker in get_children():
		_refresh_spawn(marker)
