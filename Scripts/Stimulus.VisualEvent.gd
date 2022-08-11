extends Node

export(String) var stim_type
export var continuous = false

export var intensity = 1.0
export var radius = 0.0

var collisions = []

signal triggered


func _physics_process(delta):
	
	var new_collisions = []
	
	for actor in $'/root/Mission/Actors'.get_children():
		
		if actor == owner or not actor.has_node('Vision'):
			continue
		
		var within_distance = radius == 0 or owner.global_transform.origin.distance_to(actor.global_transform.origin) < radius
		var within_vision = actor.get_node('Vision')._is_visible(actor, intensity)
		
		if within_distance and within_vision:
			
			if continuous or not actor in collisions:
				
				ActorServer.Stim(actor, stim_type, owner)
				
				emit_signal('triggered', {})
			
			new_collisions.append(actor)
	
	
	collisions = new_collisions
