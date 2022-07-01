extends Node

export(String) var stim_type
export var stim_intensity = 0.0
export var one_shot = false
export(int, LAYERS_3D_PHYSICS) var raycast_collision_mask = 0
export var length = 1.0

var active = true

onready var collision = get_node_or_null('../Collision')
onready var movement = get_node_or_null('../Movement')


func _on_before_move(velocity):
	
	if not active or owner.is_queued_for_deletion() or (collision and collision.disabled):
		return
	
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
			movement._get_speed() * -1 if stim_intensity == 0 else stim_intensity,
			result.position,
			result.normal * -1
			)


func _ready():
	
	movement.connect('before_move', self, '_on_before_move')


func _physics_process(delta):
	
	return
	
	if not active or owner.is_queued_for_deletion() or (collision and collision.disabled):
		return

	var space_state = owner.get_world().direct_space_state
	var result = space_state.intersect_ray(
		owner.global_transform.origin,
		owner.global_transform.origin + (owner.global_transform.basis.z * length),
		[owner] + movement.collision_exceptions,
		owner.collision_mask
		)

	if not result.empty():

		Meta.StimulateActor(
			result.collider, 
			stim_type,
			owner, 
			movement._get_speed() * -1 if stim_intensity == 0 else stim_intensity,
			result.position,
			result.normal * -1
			)
