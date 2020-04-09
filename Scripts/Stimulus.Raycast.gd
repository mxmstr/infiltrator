extends RayCast

export(String) var stim_type
export var continuous = false
export var send_to_self = false

export(NodePath) var path
export(String) var bone_name
export(String, MULTILINE) var required_tags

var root
var selection

signal selection_changed


func _has_selection():
	
	if get_collider() == null or get_collider().get('tags') == null:
		return false
	
	for item_tag in required_tags.split(' '):
		if not item_tag in get_collider().tags:
			return false
	
	return true


func _stimulate():
	
	if stim_type == '':
		return
	
	
	if send_to_self:
			
		if owner.has_node('Receptor'):
		
			var data = {
				'collider': get_collider(),
				'position': get_collision_point(),
				'normal': get_collision_normal() * -1,
				'travel': $'../Movement'.velocity * -1
				}
			
			owner.get_node('Receptor')._start_state(stim_type, data)
	
	else:
		
		if get_collider().has_node('Receptor'):
				
			var data = {
				'collider': get_collider(),
				'position': get_collision_point(),
				'normal': get_collision_normal(),
				'travel': $'../Movement'.velocity
				}
			
			get_collider().get_node('Receptor')._start_state(stim_type, data)


func _update_raycast_selection():
	
	if selection != get_collider():
		
		if _has_selection():
		
			selection = get_collider()
			_stimulate()
		
		else:
			
			selection = null
		
		emit_signal('selection_changed', selection)


func _ready():
	
	root = BoneAttachment.new()
	get_node(path).call_deferred('add_child', root)
	
	if bone_name != '':
		root.bone_name = bone_name
	
	#add_exception(owner)


func _process(delta):
	
	global_transform.origin = root.global_transform.origin
	global_transform.basis = root.global_transform.basis
	
	_update_raycast_selection()