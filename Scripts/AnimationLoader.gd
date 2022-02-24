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


func _load_animations(_schema, _prefix=''):
	
	if not _schema or _schema == '':
		return
	
	var owner_tags = owner.tags_dict.keys()
	var schema_animation_player = Meta.LoadSchema(_schema, owner_tags).instance()
	
	var _animation_list = Array(schema_animation_player.get_animation_list())
	var _attributes
	
	if schema_animation_player.get('attributes'):
		_attributes = parse_json(schema_animation_player.attributes)#Meta._merge_dir(attributes, parse_json(schema_animation_player.attributes))
	
	
	for animation_name in _animation_list:
		
		var animation_res = schema_animation_player.get_animation(animation_name)
		animation_player.add_animation(animation_name, animation_res)
		
		animation_name = _prefix + animation_name
		
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
