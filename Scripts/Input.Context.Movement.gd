extends Node

onready var parent = $'../../../'


func enable():
	
	set_process(true)
	set_physics_process(true)
	set_process_input(true)


func disable():
	
	set_process(false)
	set_physics_process(false)
	set_process_input(false)


func _physics_process(delta):
	
	var direction = Vector3()
	
	var cam_xform = parent.global_transform
	
	if Input.is_action_pressed('Forward'):
		direction += -cam_xform.basis.z
	if Input.is_action_pressed('Backward'):
		direction += cam_xform.basis.z
	if Input.is_action_pressed('Left'):
		direction += -cam_xform.basis.x
	if Input.is_action_pressed('Right'):
		direction += cam_xform.basis.x
	
	direction.y = 0
	parent.get_node('HumanMovement').direction = direction.normalized()
