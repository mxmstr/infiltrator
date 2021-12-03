extends Node

var speed = 0.0 setget _set_speed, _get_speed
export var direction = Vector3() setget _set_direction
var velocity = Vector3()
export var angular_direction = Vector2()
var angular_velocity = Vector2()
var pitch = 0.0
var collisions setget _set_collisions, _get_collisions
var collision_exceptions = []


func _set_collisions(new_collisions):
	
	collisions = new_collisions


func _get_collisions():
	
	return []


func _set_speed(new_speed): 
	
	speed = new_speed


func _get_speed(): 
	
	return speed


func _set_direction(new_direction, local=false):
	
	direction = new_direction


func _get_forward_speed(): return 0


func _get_sidestep_speed(): return 0


func _set_vertical_velocity(vertical):
	
	velocity.y = vertical


func _teleport(new_position=null, new_rotation=null): pass


func _turn(delta): pass


func _look(delta): pass


func _face(target, angle_delta=0.0): pass
