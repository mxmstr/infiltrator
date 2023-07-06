extends AnimationRootNode

const camera_rig_track_path = '../../Perspective'

@export var blendspace: String

@export var chain = false

@export var update_mode = 'process' # (String, 'process', 'state_starting')
@export var speed = 0.0

@export var x_target: String
@export var x_method: String
@export var x_args: Array
@export var x_max_value: float
@export var x_min_value: float

@export var y_target: String
@export var y_method: String
@export var y_args: Array
@export var y_max_value: float
@export var y_min_value: float

var node_name
var owner
var parent
var parameters
var connections = []
var advance = false

var children = get_children()
var animation_nodes = []
var statemachine_nodes = []
var is_2d
var x_min
var y_min
var x_value_range
var y_value_range

var target_pos = Vector2()
var animation_player
var x_target_node
var y_target_node

signal playing


func _on_state_starting(new_name):
	
	if node_name == new_name:
		
		advance = chain
		
		if update_mode == 'state_starting':
			_update()


func _filter_anim_events(is_action, filter_all=false):

	var blend_position = parameters + 'blend_position'
	var closest_point = call('get_closest_point', owner.get(blend_position))

	for animation_node in animation_nodes:

		var is_closest = int(animation_node) == closest_point
		
		if not is_closest or filter_all:
			children[animation_node].call_methods = false  
		else:
			children[animation_node].call_methods = true
	

	for statemachine_node in statemachine_nodes:

		var is_closest = int(statemachine_node) == closest_point
		
		if is_closest:
			children[statemachine_node]._filter_anim_events(is_action, filter_all)
		else:
			children[statemachine_node]._filter_anim_events(is_action, true)


func _unfilter_anim_events():
	
	for animation_node in animation_nodes:
		
		children[animation_node].call_methods = true
	

	for statemachine_node in statemachine_nodes:
		
		children[statemachine_node]._unfilter_anim_events()


func _update():

	var x_value = 0
	var y_value = 0
	
	if x_target_node:
		x_value = x_target_node.callv(x_method, x_args)
		x_value = (((x_value - x_min_value) / (x_max_value - x_min_value)) * x_value_range) + x_min
		
	if y_target_node:
		y_value = y_target_node.callv(y_method, y_args)
		y_value = (((y_value - y_min_value) / (y_max_value - y_min_value)) * y_value_range) + y_min

	target_pos = Vector2(x_value, y_value)


func __ready(_owner, _parent, _parameters, _node_name):

	owner = _owner
	parent = _parent
	parameters = _parameters
	node_name = _node_name
	
	animation_player = owner.get_node_or_null('AnimationPlayer')
	x_target_node = owner.owner.get_node(x_target) if x_target.length() else null
	y_target_node = owner.owner.get_node(y_target) if y_target.length() else null
	
	is_2d = get_class() == 'AnimationNodeBlendSpace2D'
	x_min = get('min_space').x if is_2d else get('min_space')
	y_min = get('min_space').y if is_2d else get('min_space')
	x_value_range = get('max_space').x - get('min_space').x if is_2d else get('max_space') - get('min_space')
	y_value_range = get('max_space').y - get('min_space').y if is_2d else get('max_space') - get('min_space')
	
	if parent != null and owner.get(parent.parameters + 'playback') != null:
		owner.get(parent.parameters + 'playback').connect('state_starting',Callable(self,'_on_state_starting'))
	
	owner.connect('on_process',Callable(self,'__process'))
	
	
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
		
		
		if child is AnimationNodeAnimation:

			animation_nodes.append(child_name)

		elif child is AnimationNodeStateMachine or \
			child is AnimationNodeBlendTree or \
			child is AnimationNodeBlendSpace1D or \
			child is AnimationNodeBlendSpace2D:
			
			if not child.has_method('_filter_anim_events'):
				continue
			
			statemachine_nodes.append(child_name)


func __process(delta):

	if update_mode == 'process':
		_update()

	if target_pos == null:
		return

	var blend_position = parameters + 'blend_position'

	if speed > 0:

		var current_pos = owner.get(blend_position) if is_2d else Vector2(owner.get(blend_position), 0)
		var new_pos = current_pos.lerp(target_pos, delta * speed)

		owner.set(blend_position, new_pos if is_2d else new_pos.x)

	else:
		
		owner.set(blend_position, target_pos if is_2d else target_pos.x)
