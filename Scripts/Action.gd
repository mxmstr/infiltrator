extends "res://Scripts/AnimationLoader.gd"

@export var state: String

var data = {}
var new_data = {}

@onready var behavior = $'../../Behavior'


func _ready():
	
	await get_tree().idle_frame
	
	tree_node.connect('action_started',Callable(self,'_on_action'))


func _play(_state, _animation, _attributes_prefix='', _down=null, _up=null):
	
	var attributes_name = _attributes_prefix + _animation
	var attributes_cloned = attributes[attributes_name].duplicate()
	
	if new_data.has('override'):
		attributes_cloned.override = true
	
	var result
	
	if _up and _down:
		result = tree_node._play(_state, _animation, attributes_cloned, new_data, _up, _down)
	else:
		result = tree_node._play(_state, _animation, attributes_cloned, new_data)
	
	if random:
		_randomize_animation()
	
	return result


func _state_start(): pass


func _state_end(): pass


func _on_state_started(new_state):
	
	if new_state != state:
		
		_state_end()
		
		behavior.disconnect('state_started',Callable(self,'_on_state_started'))


func _on_action(_state, _data):
	
	new_data = _data
	
	if _state == state and _play(state, animation_list[0]):
		
		data = new_data
		
		if not behavior.is_connected('state_started',Callable(self,'_on_state_started')):
			behavior.connect('state_started',Callable(self,'_on_state_started'))
		
		_state_start()
