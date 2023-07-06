@tool
extends AnimationNodeBlendTree

const schemas_dir = 'res://Scenes/Schemas/'
const schemas_extension = '.schema.tscn'

@export var chain = false
@export var schema: String

var node_name
var owner
var parent
var parameters
var connections = []
var nodes = []
var advance = false

var animation_list = []

signal state_starting
signal travel_starting


func _on_state_starting(new_name):
	
	if node_name == new_name:
		advance = chain


func _filter_anim_events(is_action, filter_all=false):
	
	pass


func _unfilter_anim_events():
	
	pass


func _load_animations():
	
	if schema == null or schema == '' or not owner.has_node('../Model'):
		return
	
	
	var animation_player = owner.get_node('AnimationPlayer')
	var owner_tags = []
	
	if owner.owner._has_tag(owner.schema_type):
		owner_tags = owner.owner._get_tag(owner.schema_type)
	
	var files = Meta._get_files_recursive(schemas_dir, schema, schemas_extension, owner_tags)
	
	var schema_animation_player = load(files[0]).instantiate()
	animation_list = Array(schema_animation_player.get_animation_list())
	
	for animation_name in animation_list:
		
		var animation_res = schema_animation_player.get_animation(animation_name)
		animation_player.add_animation_library(animation_name, animation_res)
	
	get_node('Default').animation = animation_list[0]
	get_node('Down').animation = animation_list[1]
	get_node('Up').animation = animation_list[2]


func _editor_ready(_owner, _parent, _parameters, _name):
	
	var children = get_children()

	for child_name in children:
		
		var child = children[child_name]
		
		if child.has_method('_editor_ready'):

			if child is AnimationNodeStateMachine or \
				child is AnimationNodeBlendTree or \
				child is AnimationNodeBlendSpace1D or \
				child is AnimationNodeBlendSpace2D:
				child._editor_ready(_owner, self, _parameters + child_name + '/', child_name)
			else:
				child._editor_ready(_owner, self, _parameters, child_name)


func __ready(_owner, _parent, _parameters, _node_name):
	
	return
	
	owner = _owner
	parent = _parent
	parameters = _parameters
	node_name = _node_name
	
	if parent != null and owner.get(parent.parameters + 'playback') != null:
		owner.get(parent.parameters + 'playback').connect('state_starting',Callable(self,'_on_state_starting'))
	
	owner.connect('on_process',Callable(self,'__process'))


	var children = get_children()

	for child_name in children:
		
		var child = children[child_name]
		
		if child.has_method('__ready'):

			if child is AnimationNodeStateMachine or \
				child is AnimationNodeBlendTree or \
				child is AnimationNodeBlendSpace1D or \
				child is AnimationNodeBlendSpace2D:
				child.__ready(owner, self, parameters + child_name + '/', child_name)
			else:
				child.__ready(owner, self, parameters, child_name)
	
	
	_load_animations()


func __process(delta):
	
	if advance:
		owner.advance(0.01)
	
	advance = false
