extends "res://Scripts/Actor.Human.gd"

export var SENSITIVITY = 0.002


func look_updown_rotation(rotation=0):
	
	var toReturn = $Camera.get_rotation() + Vector3(rotation, 0, 0)
	toReturn.x = clamp(toReturn.x, PI / -2, PI / 2)
	
	return toReturn


func look_leftright_rotation(rotation=0):
	
	return get_rotation() + Vector3(0, rotation, 0)


func mouse(event):
	
	$Camera.set_rotation(look_updown_rotation(event.relative.y * -SENSITIVITY))
	set_rotation(look_leftright_rotation(event.relative.x * -SENSITIVITY))


func _ready():
	
	set_process_input(true)


func _input(event):
	
	if event is InputEventMouseMotion:
		return mouse(event)


func _enter_tree():
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _leave_tree():
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _physics_process(delta):
	
	direction = Vector3()
	var cam_xform = get_global_transform()
	
	if Input.is_action_pressed('Forward'):
		direction += -cam_xform.basis.z
	if Input.is_action_pressed('Backward'):
		direction += cam_xform.basis.z
	if Input.is_action_pressed('Left'):
		direction += -cam_xform.basis.x
	if Input.is_action_pressed('Right'):
		direction += cam_xform.basis.x
	
	direction.y = 0
	direction = direction.normalized()
	
	