extends Area

export(String) var stim_type

onready var collision = get_node_or_null('../Collision')
onready var movement = get_node_or_null('../Movement')


func _on_body_shape_entered(body_id, body, body_shape, area_shape):
	
	if not collision or collision.disabled:
		return
	
	if body in movement.collision_exceptions:
		return
	
	Meta.StimulateActor(body, stim_type, owner)


func _on_body_shape_exited(body_id, body, body_shape, area_shape):
	
	pass


func _ready():
	
	connect('body_shape_entered', self, '_on_body_shape_entered')
	connect('body_shape_exited', self, '_on_body_shape_exited')
