extends 'res://Scripts/Link.gd'

var follow_source = false
#export var update_position = false
#export var update_rotation = false

var processed = false
var physics_processed = false


func _ready():
	
	if is_queued_for_deletion():
		return
	
	from_node.global_transform.origin = to_node.global_transform.origin
	from_node.global_transform.basis = to_node.global_transform.basis
	
	follow_source = from_node._has_tag('EventFollowSource')


func _process(delta):
	
	if follow_source:
		from_node.global_transform.origin = to_node.global_transform.origin
		from_node.global_transform.basis = to_node.global_transform.basis
	
	if processed and physics_processed:
		
		if LinkServer.GetAll(from_node, null, 'EventSubject').size() == 0:
			ActorServer.Destroy(from_node)
	
	processed = true


func _physics_process(delta):
	
	physics_processed = true
