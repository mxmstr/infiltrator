extends AnimationTree


signal on_process


func _process(delta):
	
	emit_signal('on_process', delta)
