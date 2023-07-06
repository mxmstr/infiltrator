class_name QodotFGDPointClass
extends QodotFGDClass
@tool

func _init():
	prefix = "@PointClass"

@export var scene: String : String = QodotUtil.CATEGORY_STRING

# The scene file to associate with this PointClass
# On building the map, this scene will be instanced into the scene tree
@export var scene_file: PackedScene : PackedScene

@export var scripting: String : String = QodotUtil.CATEGORY_STRING

# The script file to associate with this PointClass
# On building the map, this will be attached to any brush entities created
# via this classname if no scene_file is specified
@export var script_class: Script : Script
