extends CPUParticles


func _ready():
	
	emitting = true
	
	var time = (lifetime * 2) / speed_scale
	get_tree().create_timer(time).connect('timeout', self, 'queue_free')

#	yield(get_tree().create_timer(2.0), "timeout")
#
#	show()


#func _process(delta):
#
#	if not emitting:
#		yield(get_tree().create_timer(2.0), "timeout")
#		queue_free()