extends Node

@export var stim_type: String
@export var continuous = false

@export var intensity = 1.0
@export var radius = 0.0

var collisions = []

signal triggered


func _physics_process(delta):
	
	var new_collisions = []
	
	for actor in $'/root/Mission/Actors'.get_children():
		
		if actor == owner or not actor.has_node('Hearing'):
			continue
		
		var within_distance = radius == 0 or owner.global_transform.origin.distance_to(actor.global_transform.origin) < radius
		var within_hearing = actor.get_node('Hearing')._is_audible(actor, intensity)
		
		if within_distance and within_hearing:
			
			if continuous or not actor in collisions:
				
				ActorServer.Stim(actor, stim_type, owner)
				
				emit_signal('triggered', {})
			
			new_collisions.append(actor)
	
	
	collisions = new_collisions
