extends KinematicBody

const GRAVITY = -9.8
const MAX_SPEED = 5
const JUMP_SPEED = 7
const ACCEL= 2
const DEACCEL= 4
const MAX_SLOPE_ANGLE = 30

var direction = Vector3()
var velocity = Vector3()


func _physics_process(delta):
	
	velocity.y += delta * GRAVITY
	
	var hvelocity = velocity
	hvelocity.y = 0
	
	var target = direction * MAX_SPEED
	var accel
	if direction.dot(hvelocity) > 0:
		accel = ACCEL
	else:
		accel = DEACCEL
		
	hvelocity = hvelocity.linear_interpolate(target, accel * delta)
	
	velocity.x = hvelocity.x
	velocity.z = hvelocity.z
	
	velocity = move_and_slide(velocity, Vector3(0, 1, 0))
