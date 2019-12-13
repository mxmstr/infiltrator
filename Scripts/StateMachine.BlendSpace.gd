extends AnimationRootNode

export(String, 'process', 'state_starting') var update_mode = 'process'

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
var parent
var parameters
var transitions = []


func _update():
	
	if get_class() == 'AnimationNodeBlendSpace1D':

		var x_value = parent.owner.get_node(x_target).callv(x_method, x_args)
		x_value = (((x_value - x_min_value) / (x_max_value - x_min_value)) * (get('max_space') - get('min_space'))) + get('min_space')

		print(x_value)
		parent.set(parameters + '/' + node_name + '/blend_position', x_value)

	if get_class() == 'AnimationNodeBlendSpace2D':
	
		var x_value = parent.owner.get_node(x_target).callv(x_method, x_args)
		x_value = (((x_value - x_min_value) / (x_max_value - x_min_value)) * (get('max_space').x - get('min_space').x)) + get('min_space').x
		
		var y_value = parent.owner.get_node(y_target).callv(y_method, y_args)
		y_value = (((y_value - y_min_value) / (y_max_value - y_min_value)) * (get('max_space').y - get('min_space').y)) + get('min_space').y
		
		parent.set(parameters + '/' + node_name + '/blend_position', Vector2(x_value, y_value))


func _on_state_starting(new_name):
	
	if node_name == new_name and update_mode == 'state_starting':
		_update()


func _ready(_parent, _parameters, _node_name):
	
	parent = _parent
	parameters = _parameters
	node_name = _node_name
	
	parent.connect('state_starting', self, '_on_state_starting')
	parent.connect('on_process', self, '_process')


func _process(delta):
	
	if update_mode == 'process':
		_update()