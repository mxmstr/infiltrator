extends Node

export(PackedScene) var source

var bone_attachments = []
var hitboxes = []

onready var skeleton = get_node('../Model').get_child(0)


func _add_children():
	
	for child in source.instance().get_child(0).get_children():
		
		if child is BoneAttachment:
			
			var new_bone = BoneAttachment.new()
			new_bone.bone_name = child.bone_name
			owner.get_node('Model').get_child(0).add_child(new_bone)
			new_bone.name = child.name
			
			for hitbox in child.get_children():
				
				var export_props = {}
				
				for prop in hitbox.get_property_list():
					if prop.usage == 8199:
						export_props[prop.name] = hitbox.get(prop.name)
				
				var new_hitbox = hitbox.duplicate()
				new_bone.add_child(new_hitbox)
				
				new_hitbox.name = child.name
				
				for prop in export_props:
					new_hitbox.set(prop, export_props[prop])
				
				new_hitbox.set_owner(owner)
				
				hitboxes.append(new_hitbox)
			
			bone_attachments.append(new_bone)


func _ready():
	
	yield(get_tree(), 'idle_frame')
	
	_add_children()
