extends Spatial


export var speed = 0.0
export var gravity = -9.8

var direction = Vector3()
var velocity = Vector3()


func _set_speed(new_speed):
	
	speed = new_speed


func _set_direction(local_direction):
	
	direction = owner.global_transform.basis.xform(local_direction).normalized()


func _physics_process(delta):
	
	velocity.y += delta * gravity
	velocity = owner.move_and_slide(direction * speed, Vector3(0, 1, 0))
