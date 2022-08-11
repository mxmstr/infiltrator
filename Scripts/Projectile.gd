class_name Projectile
extends Reference

var system_path : String
var visible = true
var transform : Transform
var direction : Vector3
var angular_direction : Vector2
var speed : float
var collision_shape : RID
var collision_exceptions : Array
var tags_dict : Dictionary

func get_parent():
	return ProjectileServer
