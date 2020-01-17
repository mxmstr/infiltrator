extends AnimationNodeBlendSpace2D

const camera_rig_track_path = '../../Perspective'

export(String, 'process', 'state_starting') var update_mode = 'process'
export var speed = 0.0

export(String) var x_target
export(String) var x_method
export(Array) var x_args
export(float) var x_max_value
export(float) var x_min_value

export(String) var y_target
export(String) var y_method
export(Array) var y_args
export(float) var y_max_value
export(float) var y_min_value

var node_name
var owner
var parent
var parameters
var connections = []
var nodes = []

var target_pos


func _filter_anim_events(is_action, filter_all=false):

	var blend_position = parameters + 'blend_position'
	var closest_point = get_closest_point(owner.get(blend_position))


	for point in get_blend_point_count():

		var node = get_blend_point_node(point)
		var is_closest = point == closest_point

		if node is AnimationNodeAnimation:

			var animation = owner.get_node('AnimationPlayer').get_animation(node.animation)

			for track in animation.get_track_count():

				var is_function_call = animation.track_get_type(track) == 2
				var is_camera_and_overriden = is_action and camera_rig_track_path in str(animation.track_get_path(track))

				animation.track_set_enabled(track, false if ((is_function_call and not is_closest) or filter_all) else true)# or is_camera_and_overriden else true)


		if node is AnimationNodeBlendSpace2D or node is AnimationNodeStateMachine:

			node._filter_anim_events(is_action, filter_all) if is_closest else node._filter_anim_events(is_action, true)


func _unfilter_anim_events():
	
	for point in get_blend_point_count():

		var node = get_blend_point_node(point)

		if node is AnimationNodeAnimation:

			var animation = owner.get_node('AnimationPlayer').get_animation(node.animation)

			for track in animation.get_track_count():
				animation.track_set_enabled(track, true)

		if node is AnimationNodeBlendSpace2D:

			node._unfilter_anim_events()


func _update():

	var x_value = 0
	var y_value = 0

	if len(x_target) > 0:
		x_value = owner.owner.get_node(x_target).callv(x_method, x_args)
		x_value = (((x_value - x_min_value) / (x_max_value - x_min_value)) * (get('max_space').x - get('min_space').x)) + get('min_space').x

	if len(y_target) > 0:
		y_value = owner.owner.get_node(y_target).callv(y_method, y_args)
		y_value = (((y_value - y_min_value) / (y_max_value - y_min_value)) * (get('max_space').y - get('min_space').y)) + get('min_space').y

	target_pos = Vector2(x_value, y_value)


func _on_state_starting(new_name):

	if node_name == new_name and update_mode == 'state_starting':
		_update()


func _ready(_owner, _parent, _parameters, _node_name):

	owner = _owner
	parent = _parent
	parameters = _parameters
	node_name = _node_name

	parent.connect('state_starting', self, '_on_state_starting') if parent != null else null
	owner.connect('on_process', self, '_process')


	for point in range(get_blend_point_count()):

		var node = get_blend_point_node(point)

		if node.has_method('_ready'):

			if node is AnimationNodeStateMachine or node is AnimationNodeBlendSpace2D:
				node._ready(owner, self, parameters + str(point) + '/', str(point))
			else:
				node._ready(owner, self, parameters, str(point))

		nodes.append(node)


func _process(delta):

	if update_mode == 'process':
		_update()

	if target_pos == null:
		return

	var blend_position = parameters + 'blend_position'

	if speed > 0:
		
		var current_pos = owner.get(blend_position)
		owner.set(blend_position, current_pos.linear_interpolate(target_pos, delta * speed))

	else:

		owner.set(blend_position, target_pos)