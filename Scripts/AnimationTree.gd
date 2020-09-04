extends AnimationTree

export(String, 'Action', 'Sound') var schema_type = 'Action'

var make_unique = 0
var advances = 0

signal on_physics_process
signal on_process
signal travel_starting


func _on_pre_call_method_track(_animation, track_index, key_index):
	
	var key = _animation.track_get_key_value(track_index, key_index)
	
	for index in range(key.args.size()):
		
		var arg = key.args[index]
		
		if arg is String and arg.begins_with('$'):
			key.args[index] = get_indexed(arg.replace('$', ''))
			_animation.track_set_key_value(track_index, key_index, key)
	
	#print(str(owner.get_tree().get_frame()), ' pre_call ', key.method, ' ', key.args)


func _on_post_call_method_track(_animation, track_index, key_index):
	
	#print(str(owner.get_tree().get_frame()), ' post_call ')
	pass#print('post_call ', _animation.track_get_key_value(track_index, key_index))


func _start_state(_name, data={}):
	
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
	
	emit_signal('on_process', delta)