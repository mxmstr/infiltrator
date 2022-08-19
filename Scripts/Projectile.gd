class_name Projectile
extends Reference

var system_path : String
var visible = true
var transform : Transform
var global_transform : Transform setget _set_global_transform, _get_global_transform
var direction : Vector3
var angular_direction : Vector2
var speed : float
var model : RID
var particles : RID
var collision_shape_rid : RID
var collision_exceptions : Array
var tags_dict : Dictionary


func get_parent():
	
	return ProjectileServer


func look_at(target, up):
	
	var lookat = Transform()
	lookat.origin = transform.origin
	lookat = lookat.looking_at(target, up)
	transform = lookat


func _has_tag(tag):
	
	return tags_dict.has(tag)


func _has_tags(_tags):
	
	return tags_dict.has_all(_tags)


func _get_tag(tag):
	
	return tags_dict[tag]


func _get_tags(_tag):
	
	var matching = []
	
	for tag in tags_dict:
		if _tag in tag:
			matching.append(tags_dict[tag])
	
	return matching


func _set_tag(tag, value):
	
	tags_dict[tag] = value


func _set_global_transform(new_global_transform):
	
	transform = new_global_transform


func _get_global_transform():
	
	return transform
