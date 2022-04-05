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

enum Mode {
	DEFAULT,
	WALLRUN
}

const wall_run_vertical_speed = 4
const wall_run_vertical_mult = 2
const wall_run_horizontal_mult = 2

export(float) var forward_speed setget _set_forward_speed
export(float) var sidestep_speed setget _set_sidestep_speed

export(StanceType) var stance = StanceType.STANDING setget _set_stance
export(SpeedType) var speed = SpeedType.RUNNING
export(LeanDirection) var lean = LeanDirection.DEFAULT
export(Mode) var mode = Mode.DEFAULT

export var max_speed = 5.0
export var walk_mult = 0.3
export var crouch_mult = 0.25
export var crawl_mult = 0.15

export var max_slope_angle = 30

var collision_height
var collision_height_mult = 1.0

var speed_mult = 1.0
var rotate_speed_mult = 1.0

var lock_stance = false
var lock_speed = false
var lock_direction = false
var lock_rotation = false
var lock_movement = false

var wall_normal = Vector3.FORWARD
var wall_forward_speed = 0.0
var wall_sidestep_speed = 0.0

onready var movement = get_node_or_null('../Movement')
onready var collision = get_node_or_null('../Collision')
onready var camera = get_node_or_null('../CameraRig/Camera')


func _turn(delta):
	
	if lock_rotation:
		return
	
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


#func _get_forward_speed():
#
#	Vector2(sidestep_speed, forward_speed)
#
#	return owner.global_transform.basis.xform_inv(velocity).z
#
#
#func _get_sidestep_speed():
#
#	return owner.global_transform.basis.xform_inv(velocity).x


func _set_forward_speed(new_speed):
	
#	if lock_movement:
#		return
	
	forward_speed = new_speed


func _set_sidestep_speed(new_speed):
	
#	if lock_movement:
#		return
	
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
		
		collision.shape.extents.y = collision_height * collision_height_mult
		collision.translation.y = collision_height * collision_height_mult


func _ready():
	
	if collision:
		collision_height = collision.shape.extents.y


func _physics_process(delta):
	
	_resize_collision()
	
	if lock_movement:
		movement.direction = Vector3()
		return
	
#	if lock_rotation:
#		movement.angulardirection = Vector3()
#		return
	
	if mode == Mode.WALLRUN:
		forward_speed = 1.0
	
	
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
	
	if mode == Mode.DEFAULT:
		
		movement._set_speed(velocity.length())
		movement._set_direction(velocity.normalized(), true)
	
	elif mode == Mode.WALLRUN:
		
		var global_rotation = owner.global_transform.basis
		var global_velocity = global_rotation.xform(velocity)
		var slide_direction = global_velocity.slide(wall_normal)
		slide_direction = slide_direction.linear_interpolate(-wall_normal, 0.1)
		
		var facing_angle_forward = global_rotation.z.angle_to(-wall_normal)
		var facing_angle_sidestep = global_rotation.z.angle_to(
			(-wall_normal).rotated(Vector3.UP, (PI / 2))
			)
		var slide_angle_forward = global_velocity.angle_to(-wall_normal)
		var slide_angle_sidestep = global_velocity.angle_to(
			(-wall_normal).rotated(Vector3.UP, (PI / 2))
			)
		
		var horizontal_speed = velocity.length() * ( min(slide_angle_forward * wall_run_horizontal_mult, PI) / PI )
		var vertical_speed = velocity.length() * ( (PI - min(slide_angle_forward * wall_run_vertical_mult, PI) ) / PI )# * wall_run_vertical_speed
		
		wall_forward_speed = max( ((PI / 2) - facing_angle_forward) / (PI / 2), 0 )
		wall_sidestep_speed = ((PI / 2) - facing_angle_sidestep) / (PI / 2)
		
		movement._set_speed(horizontal_speed)
		movement._set_direction(slide_direction.normalized())
		movement._set_vertical_velocity(vertical_speed)
