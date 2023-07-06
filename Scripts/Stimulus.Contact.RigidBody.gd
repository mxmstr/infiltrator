extends Node

@export var stim_type: String
@export var continuous = false

@onready var collision = get_node_or_null('../Collision')
@onready var movement = get_node_or_null('../Movement')


func _on_body_shape_entered(body_id, body, body_shape, local_shape):
	
	ActorServer.Stim(
		body,
		stim_type,
		owner,
		movement.speed,
		owner.global_transform.origin,
		movement.direction
		)


func _ready():
	
	owner.contact_monitor = true
	owner.max_contacts_reported = 4
	
	owner.connect('body_shape_entered',Callable(self,'_on_body_shape_entered'))
