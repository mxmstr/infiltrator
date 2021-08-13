extends Node

export(PackedScene) var source

var hitboxes = []


func _add_children():
	
	
	for child in source.instance().get_child(0).get_children():
		
		if child is BoneAttachment:
			
			var new_child = BoneAttachment.new()
			new_child.bone_name = child.bone_name
			get_node('../Model').get_child(0).add_child(new_child)
			new_child.name = child.name
			
			for hitbox in child.get_children():
				
				var export_props = {}
				
				for prop in hitbox.get_property_list():
					if prop.usage == 8199:
						export_props[prop.name] = hitbox.get(prop.name)
				
				var new_hitbox = hitbox.duplicate()
				add_child(new_hitbox)
				
				new_hitbox.name = child.name
				
				for prop in export_props:
					new_hitbox.set(prop, export_props[prop])
				
				new_hitbox.set_owner(owner)


func _enter_tree():

	_add_children()


func _process(delta):

	for hitbox in get_children():
		
		hitbox.global_transform = get_node('../Model').get_child(0).get_node(hitbox.name).global_transform