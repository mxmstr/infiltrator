extends Node


func _ready():

	owner.emitting = true

	var time = (owner.lifetime * 2) / owner.speed_scale
	get_tree().create_timer(time).connect('timeout', owner, 'queue_free')
