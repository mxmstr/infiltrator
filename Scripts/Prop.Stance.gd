extends Node

enum StanceType {
	STANDING,
	CROUCHING
	CRAWLING
}

enum SpeedType {
	STOPPED,
	WALKING,
	RUNNING
}

enum LeanDirection {
	DEFAULT,
	LEFT,
	RIGHT
}

export(float) var forward_speed setget _set_forward_speed
export(float) var sidestep_speed setget _set_sidestep_speed

export(StanceType) var stance = StanceType.STANDING setget _set_stance
export(SpeedType) var speed = SpeedType.RUNNING
export(LeanDirection) var lean = LeanDirection.DEFAULT

export var max_speed = 4.5
export var walk_mult = 0.3
export var crouch_mult = 0.25
export var crawl_mult = 0.15

export var max_slope_angle = 30

export var collision_height_mult = 1.0

var speed_mult = 1.0
var rotate_speed_mult = 1.0

var lock_stance = false
var lock_speed = false
var lock_direction = false
var lock_rotation = false
var lock_movement = false

onready var movement = get_node_or_null('../Movement')
onready var collision = get_node_or_null('../Collision')
onready var camera = get_node_or_null('../CameraRig/Camera')


func _turn(delta):
	
	if lock_rotation:
		return
	
#	print(delta)
	
	movement._turn(delta)


func _look(delta):
	
	if lock_rotation:
		return
	
	movement._look(delta)


func _set_stance(new_state):
	
	if lock_stance:
		return
		
	stance = new_state
	
	match stance:
	
		StanceType.STANDING:
			
			speed_mult = 1.0
		
		StanceType.CROUCHING:
			
			speed_mult = crouch_mult
		
		StanceType.CRAWLING:
			
			speed_mult = crawl_mult


func _set_forward_speed(new_speed):
	
	if lock_movement:
		return
	
	forward_speed = new_speed


func _set_sidestep_speed(new_speed):
	
	if lock_movement:
		return
	
	sidestep_speed = new_speed


func _set_turn_speed(new_speed):
	
	movement.angular_direction.x = new_speed * rotate_speed_mult


func _set_look_speed(new_speed):
	
	movement.angular_direction.y = new_speed * rotate_speed_mult


func _align_to_camera():
	
	var target = owner.global_transform.origin + camera.global_transform.basis.z#.inverse()
	target.y = owner.global_transform.origin.y
	owner.look_at(target, Vector3(0, 1, 0))


func _resize_collision():
	
	if collision:
		
	#	if collision_height_mult == null:
	#		return
		
		collision.shape.extents.y = collision_height_mult
		collision.translation.y = collision_height_mult


func _physics_process(delta):
	
	_resize_collision()
	
	if lock_movement:
		movement.direction = Vector3()
		return
	
#	if lock_rotation:
#		movement.angulardirection = Vector3()
#		return
	
	
	var velocity = Vector3()
	var direction = Vector2(sidestep_speed, forward_speed)
	
	if direction.length():
		
		var x2 = sidestep_speed * sidestep_speed
		var y2 = forward_speed * forward_speed
		
		if (x2 >= y2):
			velocity.x = (sign(sidestep_speed) * x2 * 1.0/sqrt(x2 + y2))
			velocity.z = (sign(sidestep_speed) * sidestep_speed * forward_speed * 1.0/sqrt(x2 + y2))

		if (x2 < y2):
			velocity.x = (sign(forward_speed) * sidestep_speed * forward_speed * 1.0/sqrt(x2 + y2))
			velocity.z = (sign(forward_speed) * y2 * 1.0/sqrt(x2 + y2))
	
	
	velocity *= max_speed * speed_mult
	
	movement._set_speed(velocity.length())
	movement._set_direction(velocity.normalized(), true)
