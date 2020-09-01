extends AnimationNodeAnimation

export var chain = false

var node_name
var owner
var parent
var parameters
var connections = []
var advance = false


func _on_state_starting(new_name):
	
	if node_name == new_name:
		advance = chain


func _on_pre_call_method_track(_animation, track_index, key_index):
	
#	var method = _animation.method_track_get_name(track_index, key_index)
#	var params = _animation.method_track_get_params(track_index, key_index)
#
#	for index in range(params.size()):
#
#		var param = params[index]
#
#		if param.begins_with('$'):
#			params[index] = owner.get_indexed('data:collider')#get_indexed(param.replace('$', ''))
	
	#_animation.track_set_key_value(track_index, key_index, )
	var key = _animation.track_get_key_value(track_index, key_index)
	
	for index in range(key.args.size()):
		
		var arg = key.args[index]
		
		if arg is String and arg.begins_with('$'):
			key.args[index] = owner.get_indexed(arg.replace('$', ''))
			_animation.track_set_key_value(track_index, key_index, key)
	
	#print('pre_call ', method, ' ', params)


func _on_post_call_method_track(_animation, track_index, key_index):
	
	pass#print('post_call ', _animation.track_get_key_value(track_index, key_index))


func _ready(_owner, _parent, _parameters, _name):
	
	owner = _owner
	parent = _parent
	parameters = _parameters
	node_name = _name
	
	if parent != null and owner.get(parent.parameters + 'playback') != null:
		owner.get(parent.parameters + 'playback').connect('state_starting', self, '_on_state_starting')
	
	owner.connect('on_process', self, '_process')
	owner.connect('pre_call_method_track', self, '_on_pre_call_method_track')
	owner.connect('post_call_method_track', self, '_on_post_call_method_track')


func _process(delta):
	
	if advance:
		owner.advance(0.01)
	
	advance = false