extends AnimationTree

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
	
	emit_signal('on_process', delta)
	
	
	#print(str(get_tree().get_frame()), ' ___')
#	for i in advances:
#		advance(0.01)
#
#	advances = 0


func _msg(msg):
	
	print(str(get_tree().get_frame()), ' ', msg)


func _input(event):
	
	return
	
	if event is InputEventKey:
		
		if event.scancode == KEY_SPACE:
			print(str(get_tree().get_frame()), ' input')
			_start_state('B')
			#tree_root._travel('B')
			#get('parameters/playback').travel('C')