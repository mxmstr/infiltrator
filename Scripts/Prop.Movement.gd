extends Node

var speed = 0.0
var direction = Vector3()
var velocity = Vector3()


func _get_collisions(): return []


func _get_speed(): pass


func _get_forward_speed(): pass


func _get_sidestep_speed(): pass


func _set_speed(new_speed): pass


func _set_vertical_velocity(vertical): pass


func _set_direction(new_direction, local=false): pass


func _teleport(new_position=null, new_rotation=null): pass


func _turn(delta): pass


func _face(target, angle_delta=0.0): pass
