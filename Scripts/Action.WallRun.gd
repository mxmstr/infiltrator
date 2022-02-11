extends "res://Scripts/Action.gd"

var active = false

onready var movement = $'../Movement'
onready var stance = $'../Stance'


func _on_action(_state, _data):
	
	if _state == 'WallRun':
		
		data = _data
		
		stance.mode = stance.Mode.WALLRUN
		stance.wall_normal = data.normal
		
		active = true
	
	elif _state == 'WallRunEnd':
		
		stance.mode = stance.Mode.DEFAULT
		
		active = false


func _process(delta):
	
	if not active:
		return
	
	if not owner.is_on_wall():
		active = false
		return
	
	return
	
	var direction = owner.global_transform.basis.z.slide(data.normal)
#	direction.y = 0
	#var motion = Transform().looking_at(direction, Vector3.UP)
	
#	owner.transform.origin += direction * delta
	
	movement._set_vertical_velocity(4)
	movement._set_direction(direction)
