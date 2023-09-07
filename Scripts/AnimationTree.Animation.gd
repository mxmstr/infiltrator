extends AnimationNodeAnimation

const schemas_dir = 'res://Scenes/Schemas/'
const schemas_extension = '.schema.tscn'

@export var chain = false
@export var schema: String

var node_name
var owner
var parent
var parameters
var connections = []
var advance = false

var default_scale
var animation_list = []
var attributes = {}
var custom_script_object

signal playing


func _load_animations():
	
	if schema == null or schema == '':# or not owner.has_node('../Model'):
		return
	
	default_scale = scale
	
	
	var animation_player = owner.get_node(owner.anim_player)
	var owner_tags = owner.owner.tags_dict.keys()
	var schema_animation_player = Meta.LoadSchema(schema, owner_tags).instantiate()
	animation_list = Array(schema_animation_player.get_animation_list())
	
	if schema_animation_player.get('attributes'):
		var test_json_conv = JSON.new()
		test_json_conv.parse(schema_animation_player.attributes)
		attributes = test_json_conv.get_data()
	
	for animation_name in animation_list:
		
		var animation_res = schema_animation_player.get_animation(animation_name)
		var library = animation_player.get_animation_library(animation_player.get_animation_library_list()[0])
		library.add_animation(animation_name, animation_res)
	
	
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
		
		emit_signal('playing')
		
		if custom_script_object:
			custom_script_object._on_state_starting()
		
		_randomize_animation()


func __ready(_owner, _parent, _parameters, _name):
	
	owner = _owner
	parent = _parent
	parameters = _parameters
	node_name = _name
	
	#print(node_name) if owner.name == 'PrimaryAction' else null
	
	if parent != null and owner.get(parent.parameters + 'playback') != null:
		owner.get(parent.parameters + 'playback').connect('state_starting', Callable(self, '_on_state_starting'))
	
	owner.connect('on_process',Callable(self,'__process'))
	
	_load_animations()


func __process(delta):
	
	if advance:
		owner.advance(0.01)
	
	advance = false
