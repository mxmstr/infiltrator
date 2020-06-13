extends Node

enum state {
	CRAWLING,
	CROUCHING,
	WALKING,
	RUNNING
}

enum lean {
	DEFAULT,
	LEFT,
	RIGHT
}

export(state) var current_state setget _set_state
export(lean) var current_lean = lean.DEFAULT

export var gravity = -9.8
export var max_speed = 2.75
export var walk_mult = 0.3
export var crouch_mult = 0.15
export var crawl_mult = 0.1

export var jump_speed = 7
export var accel = 2
export var deaccel = 4
export var max_slope_angle = 30

export var collision_height_mult = 1.0

var enable_rotation = true
var enable_movement = true

var speed = 0.0
var direction = Vector3()
var velocity = Vector3()
var target

onready var collision = $'../Collision'
#onready var ik_righthand = $'../Model'.get_child(0).get_node('RightHandIK/Target')

signal move_and_slide


func _get_forward_speed():
	
	return owner.global_transform.basis.xform_inv(velocity).z


func _get_leftright_speed():
	
	return owner.global_transform.basis.xform_inv(velocity).x


func _teleport(new_position=null, new_rotation=null):
	
	if new_position != null:
		owner.global_transform.origin = new_position
	
	if new_rotation != null:
		owner.rotation = new_rotation


func _rotate(delta):
	
	if not enable_rotation:
		return
	
	owner.rotation.y += delta


func _set_state(new_state):
	
	if not enable_movement:
		return
	
	current_state = new_state


func _set_speed(new_speed):
	
	if not enable_movement:
		return
	
	match current_state:
		
		state.WALKING:
			
			speed = new_speed * max_speed * walk_mult
		
		state.CROUCHING:
			
			speed = new_speed * max_speed * crouch_mult
		
		state.RUNNING:
			
			speed = new_speed * max_speed
		
		state.CRAWLING:
			
			speed = new_speed * max_speed * crawl_mult


func _set_direction(new_direction):
	
	if not enable_movement:
		return
	
	direction = new_direction


func _set_horizontal_velocity(horizontal):
	
	horizontal = owner.global_transform.basis.xform(horizontal)
	velocity = Vector3(horizontal.x, velocity.y, horizontal.z)


func _set_vertical_velocity(vertical):
	
	velocity.y = vertical


func _align_to_camera():
	
	var target = owner.global_transform.origin + $'../CameraRig/Camera'.global_transform.basis.z#.inverse()
	target.y = owner.global_transform.origin.y
	owner.look_at(target, Vector3(0, 1, 0))


func _resize_collision():
	
	if collision_height_mult == null:
		return
	
	collision.shape.extents.y = collision_height_mult
	collision.translation.y = collision_height_mult


func _ready():
	
	current_state = state.WALKING


func _physics_process(delta):
	
	_resize_collision()
	
	
	var vertical = velocity.y + (delta * gravity)
	var horizontal = Vector3(velocity.x, 0, velocity.z)
	
	
	var new_velocity = owner.global_transform.basis.xform(direction) * speed
	var factor
	
	if new_velocity.dot(horizontal) > 0:
		factor = accel
	else:
		factor = deaccel
	
	
	
	velocity = horizontal.linear_interpolate(new_velocity, factor * delta)
	velocity.y = vertical
	
	emit_signal('move_and_slide', delta)
	
	velocity = owner.move_and_slide(velocity, Vector3(0, 1, 0))
