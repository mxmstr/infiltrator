extends Node

const schemas_dir = 'res://Scenes/Schemas/'
const schemas_extension = '.schema.tscn'

export(NodePath) var tree
export(String) var schema
export var random = false

var tree_node
var animation_player
var animation_list = []
var attributes = {}
var animation


func _load_animations(_schema):
	
	if not _schema or _schema == '':
		return
	
	var owner_tags = owner.tags_dict.keys()
	var files = Meta._get_files_recursive(schemas_dir, _schema, schemas_extension, owner_tags)
	var schema_animation_player = load(files[0]).instance()
	
	var _animation_list = Array(schema_animation_player.get_animation_list())
	var _attributes
	
	if schema_animation_player.get('attributes'):
		_attributes = parse_json(schema_animation_player.attributes)#Meta._merge_dir(attributes, parse_json(schema_animation_player.attributes))
	
	
	for animation_name in _animation_list:
		
		var animation_res = schema_animation_player.get_animation(animation_name)
		animation_player.add_animation(animation_name, animation_res)
		
		if _attributes:
		
			if not attributes.has(animation_name):
				attributes[animation_name] = {}
			
			if _attributes.has(animation_name):
				Meta._merge_dir(attributes[animation_name], _attributes[animation_name])
			
			if '*' in _attributes.keys():
				Meta._merge_dir(attributes[animation_name], _attributes['*'])
		
		else:
			
			attributes[animation_name] = {}
	
	if random:
		randomize()
		_animation_list.shuffle()
	
	animation = _animation_list[0]
	
	return _animation_list


func _randomize_animation():
	
	if len(animation_list) > 0:
		
		randomize()
		animation_list.shuffle()
		animation = animation_list[0]


func _ready():
	
	if not tree.is_empty():
		
		tree_node = get_node(tree)
		animation_player = tree_node.get_node('AnimationPlayer')
	
	animation_list = _load_animations(schema)


#func _play(_animation):
#
#	var anim_attr = attributes[_animation]
#
#	var speed = 1.0
#	var blend = -1.0
#	var clip_start = 0
#	var clip_end = 0
#
#	if anim_attr.has('speed'):
#		speed = anim_attr.speed
#
#	if anim_attr.has('blend'):
#		blend = anim_attr.blend
#
#	if anim_attr.has('clip_start'):
#		clip_start = anim_attr.clip_start
#
#	if anim_attr.has('clip_end'):
#		clip_end = anim_attr.clip_end
#
#	animation_player.play(_animation, blend, speed)
#
#	if random:
#		_randomize_animation()


#func _start():
#
#	_play(animation)
#	_randomize_animation()
