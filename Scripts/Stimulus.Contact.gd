extends Node

@export var stim_type: String
@export var stim_intensity = 0.0
@export var one_shot = false
@export var continuous = false
@export var raycast = false

var active = true
var collisions = []

@onready var collision = get_node_or_null('../Collision')
@onready var movement = get_node_or_null('../Movement')


func _ready():
	
	pass


#func _test_raycast():
#
#	var space_state = owner.get_world_3d().direct_space_state
#	var 
#
#	var result = space_state.intersect_ray(
#		collision.global_transform.origin, target_pos, [owner], owner.collision_mask
#		)
#
#
#	return


func _physics_process(delta):
	
	if not active or owner.is_queued_for_deletion() or (collision and collision.disabled):
		return
	
	
	var colliders = []
	
	for collision_ in collisions:
		colliders.append(collision_.collider)
	
	
	var new_collisions = []
	
	for collision_ in movement._get_collisions():
		
		if continuous or not collision_.collider in colliders:
			
			ActorServer.Stim(
				collision_.collider,
				stim_type,
				owner,
				movement._get_speed() * -1 if stim_intensity == 0 else stim_intensity,
				collision_.position,
				collision_.normal * -1
				)
		
		new_collisions.append(collision_)
	
	collisions = new_collisions
	
	if one_shot:
		active = false
