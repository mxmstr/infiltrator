extends Spatial

export var limit = 50

onready var actors = $Actors

func _process(delta):
	
	for actor in actors.get_children():
		if actor.translation.length() > 100:
			actor.queue_free()
