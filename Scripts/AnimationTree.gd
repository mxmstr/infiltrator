extends AnimationTree

export(String, 'Action', 'Sound') var schema_type = 'Action'

var make_unique = 0
var advances = 0
var data

signal on_physics_process
signal on_process
signal travel_starting


func _on_pre_call_method_track(_animation, track_index, key_index):
	
	var key = _animation.track_get_key_value(track_index, key_index)
	Meta.cached_args = key.args.duplicate()
	
	for index in range(key.args.size()):
		
		var arg = key.args[index]
		
		if arg is String and arg.begins_with('$'):
			key.args[index] = get_indexed(arg.replace('$', ''))
			_animation.track_set_key_value(track_index, key_index, key)


func _on_post_call_method_track(_animation, track_index, key_index):
	
	var key = _animation.track_get_key_value(track_index, key_index)
	key.args = Meta.cached_args
	
	_animation.track_set_key_value(track_index, key_index, key)


func _start_state(_name, _data={}):
	
	data = _data
	
	if tree_root.has_method('_travel'):
		tree_root._travel(_name)


func _ready():
	
	if Engine.editor_hint: return
	
	if tree_root.has_method('_ready'):
		tree_root._ready(self, null, 'parameters/', 'root')
	
	connect('pre_call_method_track', self, '_on_pre_call_method_track')
	connect('post_call_method_track', self, '_on_post_call_method_track')
	
	active = true


func _physics_process(delta):
	
	emit_signal('on_physics_process', delta)


func _process(delta):
	
	if Engine.editor_hint: return
	
#	if name == 'Interface':
#		var playback = get('parameters/playback')
#		var current_node = playback.get_current_node()
#		#print(current_node)
	
	emit_signal('on_process', delta)