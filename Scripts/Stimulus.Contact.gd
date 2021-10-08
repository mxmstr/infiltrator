extends Node

enum ContactType {
	Collision,
	Radius
}

export(String) var stim_type
export var continuous = false

export(ContactType) var contact_type = ContactType.Collision
export var max_distance = 0.0

var collisions = []

onready var collision = get_node_or_null('../Collision')
onready var movement = get_node_or_null('../Movement')


func _ready():
	
	pass


func _physics_process(delta):
	
	if not collision or collision.disabled:
		return
	
	
	var colliders = []
	
	for collision_ in collisions:
		colliders.append(collision_.collider)
	
	
	var new_collisions = []
	
	for collision_ in movement._get_collisions():
		
		if continuous or not collision_.collider in colliders:
			
			Meta.StimulateActor(
				collision_.collider,
				stim_type,
				owner,
				movement._get_speed() * -1,
				collision_.position,
				collision_.normal * -1
				)
		
		new_collisions.append(collision_)
	
	collisions = new_collisions
