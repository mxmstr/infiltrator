extends Node

export(String) var stim_type
export var raycast = false

onready var collision = get_node_or_null('../Collision')
onready var movement = get_node_or_null('../Movement')


func _on_body_shape_entered(body_id, body, body_shape, area_shape):
	
	if not collision or collision.disabled:
		return
	
	if body in movement.collision_exceptions:
		return
	
	Meta.StimulateActor(
		body, 
		stim_type,
		owner, 
		movement._get_speed() * -1,
		owner.transform.origin,
		owner.transform.basis.z * -1
		)


func _on_body_shape_exited(body_id, body, body_shape, area_shape):
	
	pass


func _on_before_move(velocity):
	
	if raycast:
		
		var space_state = owner.get_world().direct_space_state
		var result = space_state.intersect_ray(
			owner.transform.origin, 
			owner.transform.origin + velocity, 
			[owner] + movement.collision_exceptions, 
			owner.collision_mask
			)
		
		if not result.empty():
			
			Meta.StimulateActor(
				result.collider, 
				stim_type,
				owner, 
				movement._get_speed() * -1,
				result.position,
				result.normal * -1
				)


func _ready():
	
	if raycast:
		movement.connect('before_move', self, '_on_before_move')
	else:
		owner.connect('body_shape_entered', self, '_on_body_shape_entered')
		owner.connect('body_shape_exited', self, '_on_body_shape_exited')


func _physics_process(delta):
	
	if not collision or collision.disabled:
		return
	
	if raycast:
	
		var space_state = owner.get_world().direct_space_state
		var result = space_state.intersect_ray(
			owner.transform.origin,
			owner.transform.origin + (owner.transform.basis.z * collision.shape.radius),
			[owner] + movement.collision_exceptions,
			owner.collision_mask
			)
		
		if not result.empty():
			
			Meta.StimulateActor(
				result.collider, 
				stim_type,
				owner, 
				movement._get_speed() * -1,
				result.position,
				result.normal * -1
				)
