extends Node

export(String) var stim_type
export var continuous = false
export var send_to_self = false

var collisions = []


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
			
			if collision.collider.has_node('Receptor'):
				
				var data = {
					'collider': owner, 
					'position': collision.position,
					'normal': collision.normal * -1,
					'travel': $'../Movement'.velocity
					}
				
				collision.collider.get_node('Receptor')._start_state(stim_type, data)
			
			if send_to_self and get_parent().has_node('Receptor'):
				
				var data = {
					'collider': collision.collider,
					'position': collision.position,
					'normal': collision.normal * -1,
					'travel': $'../Movement'.velocity * -1
					}
				
				get_parent().get_node('Receptor')._start_state(stim_type, data)
		
		new_collisions.append(collision)
	
	
	collisions = new_collisions
