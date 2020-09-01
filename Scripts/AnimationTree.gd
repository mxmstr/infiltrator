extends AnimationTree

export(String, 'Action', 'Sound') var schema_type = 'Action'

var make_unique = 0
var advances = 0

signal on_physics_process
signal on_process
signal travel_starting


func _start_state(_name, data={}):
	
	if tree_root.has_method('_travel'):
		tree_root._travel(_name)


func _ready():
	
	if Engine.editor_hint: return
	
	if tree_root.has_method('_ready'):
		tree_root._ready(self, null, 'parameters/', 'root')
	
	active = true


func _physics_process(delta):
	
	emit_signal('on_physics_process', delta)


func _process(delta):
	
	if Engine.editor_hint: return
	
#	if name == 'Perception':
#		print(get('parameters/playback').get_current_node())
	
	emit_signal('on_process', delta)