extends AnimationNodeAnimation

const schemas_dir = 'res://Scenes/Schemas/'
const schemas_extension = '.schema.tscn'

export var chain = false
export(String) var schema

var node_name
var owner
var parent
var parameters
var connections = []
var advance = false

var default_scale
var animation_list = []
var attributes = {}

signal state_starting


func _load_animations():
	
	if not schema or schema == '':# or not owner.has_node('../Model'):
		return
	
	default_scale = scale
	
	
	var animation_player = owner.get_node('AnimationPlayer')
	var owner_tags = owner.owner.tags_dict.keys()#[]
	
#	if owner.owner._has_tag(owner.schema_type):
#		owner_tags = owner.owner._get_tag(owner.schema_type)
	
	var files = Meta._get_files_recursive(schemas_dir, schema, schemas_extension, owner_tags)
	
	var schema_animation_player = load(files[0]).instance()
	animation_list = Array(schema_animation_player.get_animation_list())
	
	if schema_animation_player.get('attributes'):
		attributes = parse_json(schema_animation_player.attributes)
	
	for animation_name in animation_list:
		
		var animation_res = schema_animation_player.get_animation(animation_name)
		animation_player.add_animation(animation_name, animation_res)
	
	
	animation = animation_list[0]
	
	if attributes.has(animation):
		scale = default_scale * attributes[animation].speed


func _randomize_animation():
	
	if len(animation_list) > 0:
		
		animation_list.shuffle()
		animation = animation_list[0]
		
		if attributes.has(animation):
			scale = default_scale * attributes[animation].speed


func _on_state_starting(new_name):
	
	if node_name == new_name:
		
		advance = chain
		
		emit_signal('state_starting', node_name, owner.data)
	
		_randomize_animation()


func _ready(_owner, _parent, _parameters, _name):
	
	owner = _owner
	parent = _parent
	parameters = _parameters
	node_name = _name
	
	#print(node_name) if owner.name == 'PrimaryAction' else null
	
	if parent != null and owner.get(parent.parameters + 'playback') != null:
		owner.get(parent.parameters + 'playback').connect('state_starting', self, '_on_state_starting')
	
	owner.connect('on_process', self, '_process')
	
	_load_animations()


func _process(delta):
	
	if advance:
		owner.advance(0.01)
	
	advance = false
