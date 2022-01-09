extends 'res://Scripts/Prop.Movement.gd'

var new_speed
var teleporting = false
var new_position
var new_rotation


func _set_speed(_new_speed): 
	
	new_speed = _new_speed


func _get_speed(): 
	
	return owner.linear_velocity.length()


func _teleport(_new_position=null, _new_rotation=null):
	
	owner.sleeping = false
	owner.can_sleep = false
	owner.mode = 3
	
	if _new_position != null:
		new_position = _new_position
		owner.transform.origin = new_position
	
	if _new_rotation != null:
		new_rotation = _new_rotation
		owner.transform.basis = _new_rotation
	
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
	
	
	if new_speed:
		
		var new_velocity = direction * new_speed
		state.linear_velocity = Vector3()
		state.apply_central_impulse(new_velocity)
		new_speed = null
