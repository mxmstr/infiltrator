extends 'res://Scripts/Link.gd'

var spawn_links
var pickup_idx = 0


func _on_factory_finished(link):
	
	var marker = spawn_links[pickup_idx].to_node
	link.outputs[0].translation = marker.translation
	link.outputs[0].rotation = marker.rotation
	
	pickup_idx += 1
	
	if pickup_idx >= spawn_links.size():
		pickup_idx = 0


func _enter_tree():
	
	check_nulls = false


func _ready():
	
	spawn_links = Meta.GetLinks(self, null, 'PVPPlayerSpawn')
	spawn_links.shuffle()
	
	yield(get_tree(), 'idle_frame')
	
	for weapon_name in Meta.multi_loadout:
		
		var node_name = Meta.preloader.get_resource('res://Scenes/Actors/' + weapon_name + '.tscn').instance().name
		
		for file in Meta._get_files_recursive('res://Scenes/Links/Factories/', 'Factory', '.link.tscn', [node_name]):
			
			var new_link = Meta.preloader.get_resource(file).instance()
			new_link.connect('finished', self, '_on_factory_finished', [new_link])
			$'/root/Mission/Links'.add_child(new_link)
	
