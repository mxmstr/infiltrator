extends AnimationTree

signal on_physics_process
signal on_process
signal travel_starting

var level = 0


func _start_state(_name, data={}):
	
	#print(_name) if name == 'Behavior' else null
	
	if tree_root.has_method('_travel'):
		tree_root._travel(_name)


func _ready():
	
	if Engine.editor_hint: return
	
	if not has_meta('unique'):
		Inf._make_unique(self)
		return
	
	
	if tree_root.has_method('_ready'):
		tree_root._ready(self, null, 'parameters/', 'root')
	
	active = true


func _physics_process(delta):
	
	emit_signal('on_physics_process', delta)


func _process(delta):
	
	if Engine.editor_hint: return
	
	#print(tree_root.current_node) if owner.name == 'Player' and name == 'Behavior' else null
	
	emit_signal('on_process', delta)