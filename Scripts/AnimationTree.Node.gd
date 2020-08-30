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


func _on_pre_call_method_track(method, params):
	
	print('pre_call ', method, ' ', params)


func _on_post_call_method_track(method, params):
	
	print('post_call ', method, ' ', params)


func _ready(_owner, _parent, _parameters, _name):
	
	owner = _owner
	parent = _parent
	parameters = _parameters
	node_name = _name
	
	if parent != null and owner.get(parent.parameters + 'playback') != null:
		owner.get(parent.parameters + 'playback').connect('state_starting', self, '_on_state_starting')
	
	owner.connect('on_process', self, '_process')
	#owner.connect('pre_call_method_track', self, '_on_pre_call_method_track')
	#owner.connect('post_call_method_track', self, '_on_post_call_method_track')


func _process(delta):
	
	if advance:
		owner.advance(0.01)
	
	advance = false