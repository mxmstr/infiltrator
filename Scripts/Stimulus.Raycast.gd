extends RayCast3D

@export var stim_type: String
@export var auto = true
@export var one_shot = false
@export var continuous = false
@export var send_to_self = false

@export var move_target = true
@export var predict_collision = false
@export var path: NodePath
@export var bone_name: String
@export_multiline var required_tags

var required_tags_dict = {}
var root
var selection
var rotation_offset = Vector2()

@onready var movement = get_node_or_null('../Movement')
@onready var reception = get_node_or_null('../Reception')

signal selection_changed
signal triggered


func _has_selection():
	
	if not get_collider() or not get_collider().get('tags'):
		return false
	
	for item_tag in required_tags_dict.keys():
		
		if item_tag.length() and not get_collider()._has_tag(item_tag):
			return false
	
	return true


func _stimulate(stim_type_override=''):
	
	var new_stim = stim_type_override if stim_type_override != '' else stim_type
	
	if not new_stim.length() or not selection:
		return
	
	
	if send_to_self:
		ActorServer.Stim(owner, new_stim, owner, movement.velocity.length() * -1, get_collision_point(), get_collision_normal() * -1)
	else:
		ActorServer.Stim(selection, new_stim, owner, movement.velocity.length(), get_collision_point(), get_collision_normal())


func _update_raycast_selection():
	
	if _has_selection():
		selection = get_collider()
	
	emit_signal('selection_changed', selection)


func _reset_root():
	
	root.position = Vector3()
	root.rotation_degrees = Vector3()


func _on_before_move(velocity):
	
	if velocity.length() > 0:#target_position.length():
		
		var origin = owner.global_transform.origin
		var next_origin = owner.global_transform.translated(velocity).origin
		var temp_raycast = duplicate()

		owner.add_child(temp_raycast)
		temp_raycast.target_position = Vector3(0, 0, -origin.distance_to(next_origin))
		temp_raycast.force_raycast_update()

		if temp_raycast.get_collider():
			ActorServer.Stim(temp_raycast.get_collider(), stim_type, owner, velocity.length(), temp_raycast.get_collision_point(), temp_raycast.get_collision_normal())
		
		temp_raycast.free()


func _ready():
	
	for tag in required_tags.split(' '):
		
		var values = Array(tag.split(':'))
		var key = values.pop_front()
		
		required_tags_dict[key] = values
	
	
	if not path.is_empty():
		
		root = BoneAttachment3D.new()
		get_node(path).call_deferred('add_child', root)
		
		if bone_name != '':
			root.bone_name = bone_name
		
		_reset_root()
	
	
	if predict_collision:
		movement.connect('before_move',Callable(self,'_on_before_move'))
	
	
	await get_tree().idle_frame
	
	if owner.has_node('Hitboxes'):
		for hitbox in owner.get_node('Hitboxes').hitboxes:
			add_exception(hitbox)


func _process(delta):
	
	if root:
		
		global_transform.origin = root.global_transform.origin
		global_transform.basis = root.global_transform.basis
		
		if rotation_offset.length():
			global_transform.basis = global_transform.basis.rotated(root.global_transform.basis.y, rotation_offset.x)
			global_transform.basis = global_transform.basis.rotated(root.global_transform.basis.x, -rotation_offset.y)
	
	if move_target and get_collision_point():
		$Target.global_transform.origin = get_collision_point()
	
	if enabled:
		_update_raycast_selection()
	
	if auto:
		_stimulate()
	
	if one_shot:
		auto = false
