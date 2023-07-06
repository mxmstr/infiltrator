class_name QodotWorldspawnLayer
extends Resource

@export var name: String := ""
@export var texture: String := ""
@export var node_class: String := ""
@export var build_visuals: bool := true
@export var collision_shape_type := QodotFGDSolidClass.CollisionShapeType.CONVEX # (QodotFGDSolidClass.CollisionShapeType)
@export var script_class: Script = null

func _init():
	resource_name = "Worldspawn Layer"
