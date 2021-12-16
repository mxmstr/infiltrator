extends Particles


func _ready():

	emitting = true

	var time = (lifetime * 2) / speed_scale
	get_tree().create_timer(time).connect('timeout', owner, 'queue_free')
