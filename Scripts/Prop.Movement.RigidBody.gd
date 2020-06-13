extends Spatial

export var speed = 0.0
export var gravity = -9.8

var direction = Vector3()
var velocity = Vector3()

var teleporting = false
var new_position = null
var new_rotation = null


func _set_speed(new_speed):
	
	speed = new_speed


func _set_direction(local_direction):
	
	direction = owner.global_transform.basis.xform(local_direction).normalized()


func _teleport(_new_position=null, _new_rotation=null):
	
	owner.sleeping = false
	owner.can_sleep = false
	owner.mode = 3
	
	if _new_position != null:
		new_position = _new_position
		owner.transform.origin = new_position
	
	if _new_rotation != null:
		new_rotation = _new_rotation
		owner.rotation = _new_rotation
	
	teleporting = true


func _ready():
	
	owner.connect('integrate_forces', self, '_integrate_forces')


func _integrate_forces(state):
	
	if teleporting:
	
		if new_position != null:
			
			state.transform.origin = new_position
			new_position = null
		
		if new_rotation != null:
	
			state.transform.basis = Basis(new_rotation)
			new_rotation = null
		
		owner.mode = 0
		owner.sleeping = false
		owner.can_sleep = true
		
		teleporting = false