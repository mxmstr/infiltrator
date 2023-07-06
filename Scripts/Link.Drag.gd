extends 'res://Scripts/Link.gd'

@export var relative = false
@export var distance = 0.0
@export var direction = Vector3(0, 0, 1)
@export var power = 1.0

var start_pos


func _on_move_and_slide():
	
	if power == 0:
		return
	
	var to_pos = to_node.global_transform.origin
	var from_pos = from_node.global_transform.origin
	var direction_to = to_pos.direction_to(from_pos)
	
	if direction_to.length() > distance:
		
		to_node.get_node('Movement').velocity.x = 0
		to_node.get_node('Movement').velocity.z = 0
		
		if relative:
			to_node.global_transform.origin = start_pos.lerp(from_pos, power)
		else:
			to_node.global_transform.origin = to_pos.lerp(from_pos, power)


func _ready():
	
	if is_queued_for_deletion():
		return
	
	start_pos = to_node.global_transform.origin
	
	to_node.get_node('Movement').connect('move_and_slide',Callable(self,'_on_move_and_slide'))
