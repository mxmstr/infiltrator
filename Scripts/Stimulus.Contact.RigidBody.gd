extends Node

export(String) var stim_type
export var continuous = false

onready var collision = get_node_or_null('../Collision')
onready var movement = get_node_or_null('../Movement')


func _on_body_shape_entered(body_id, body, body_shape, local_shape):
	
	Meta.StimulateActor(
		body,
		stim_type,
		owner,
		movement._get_speed(),
		owner.global_transform.origin,
		movement.direction
		)


func _ready():
	
	owner.contact_monitor = true
	owner.contacts_reported = 4
	
	owner.connect('body_shape_entered', self, '_on_body_shape_entered')
