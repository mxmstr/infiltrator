extends Node

export(String) var stim_type
export var continuous = false
export var send_to_self = false

var collisions = []

signal triggered


func _ready():
	
	pass


func _physics_process(delta):
	
	var colliders = []
	
	for collision in collisions:
		colliders.append(collision.collider)
	
	
	var new_collisions = []
	
	for index in range(get_parent().get_slide_count()):
		
		var collision = get_parent().get_slide_collision(index)
		
		if continuous or not collision.collider in colliders:
			
			var data
			
			if send_to_self:
				Meta.StimulateActor(owner, stim_type, owner, collision.position, collision.normal, $'../Movement'.velocity.length())
			else:
				Meta.StimulateActor(collision.collider, stim_type, owner, collision.position, collision.normal * -1, $'../Movement'.velocity.length() * -1)
			
			emit_signal('triggered', data)
		
		new_collisions.append(collision)
	
	
	collisions = new_collisions
