extends CPUParticles


func _ready():
	
	emitting = true
	
#	yield(get_tree().create_timer(2.0), "timeout")
#
#	show()


func _process(delta):
	
	if not emitting:
		queue_free()