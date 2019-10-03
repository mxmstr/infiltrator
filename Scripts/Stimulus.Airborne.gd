extends AnimationNodeStateMachineTransition

export var delay = 0.0

var parent
var timer


func _ready(_parent):
	
	parent = _parent
	
	parent.connect('on_physics_process', self, '_physics_process')


func _on_timeout():
	
	disabled = false
	
	timer.queue_free()
	timer = null


func _physics_process(delta):
	
	if parent.get_parent().is_on_floor():
		
		disabled = true
		
		if timer != null:
			timer.queue_free()
			timer = null
	
	
	elif timer == null:
		
		timer = Timer.new()
		timer.autostart = true
		timer.wait_time = delay
		parent.add_child(timer)
		
		timer.connect('timeout', self, '_on_timeout')