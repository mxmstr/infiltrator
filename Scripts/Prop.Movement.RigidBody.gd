extends 'res://Scripts/Prop.Movement.gd'

var teleporting = false
var new_position = null
var new_rotation = null


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
