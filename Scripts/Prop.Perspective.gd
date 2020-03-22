tool
extends 'res://Scripts/AnimationTree.gd'

export var mouse_device = -1
export var keyboard_device = -1
export var fp_offset = Vector3(0, 0, 0.1)
export(String) var fp_root_bone
export(String) var fp_shoulder_bone
export(Array, String) var fp_hidden_bones

export(Vector3) var rig_translation setget _set_rig_translation
export(Vector3) var rig_rotation_degrees setget _set_rig_rotation_degrees
export var cam_max_x = 0.0
export var cam_max_y = PI / 2

var player_index = 0
var viewmodel_offset = 5
var worldmodel_offset = 15

var root_id
var shoulders_id

var selection
var last_selection
var rig_translated = false
var rig_rotated = false

onready var rig = $Container/Viewport/CameraRig
onready var camera = $Container/Viewport/CameraRig/Camera
onready var raycast = $Container/Viewport/CameraRig/Camera/RayCast

signal changed_selection


func _set_rig_translation(new_translation):
	
	if not Engine.editor_hint and rig_translated:
		return
	
	rig_translation = new_translation
	rig_translated = true


func _set_rig_rotation_degrees(new_rotation):
	
	if not Engine.editor_hint and rig_rotated:
		return
	
	rig_rotation_degrees = new_rotation
	rig_rotated = true


func _reset_viewport():
	
	var camera = $Container/Viewport/CameraRig/Camera
	var mesh = $'../Model'.get_child(0).get_child(0)
	var viewmesh = $'../ViewModel'.get_child(0).get_child(0)
	
	
	camera.set_cull_mask_bit(viewmodel_offset, false)
	viewmesh.set_layer_mask_bit(viewmodel_offset, false)
	
	camera.set_cull_mask_bit(worldmodel_offset, true)
	mesh.set_layer_mask_bit(worldmodel_offset, false)
	
	
	camera.set_cull_mask_bit(viewmodel_offset + player_index, true)
	viewmesh.set_layer_mask_bit(0, false)
	viewmesh.set_layer_mask_bit(viewmodel_offset + player_index, true)
	
	camera.set_cull_mask_bit(worldmodel_offset + player_index, false)
	mesh.set_layer_mask_bit(0, false)
	mesh.set_layer_mask_bit(worldmodel_offset + player_index, true)


func _init_camera():
	
	raycast.add_exception(get_parent())
	selection = raycast.get_collider()


func _init_viewport():
	
	$Container/Viewport.world = get_tree().root.world
	$Container/Viewport.size = get_tree().root.size


func _init_fp_skeleton():
	
	var viewmodel = $'../Model'.duplicate()
	viewmodel.name = 'ViewModel'
	viewmodel.get_child(0).get_child(0).cast_shadow = 0
	
	for idx in range(viewmodel.get_child(0).get_bone_count()):
		
		var bone_name = viewmodel.get_child(0).get_bone_name(idx)
		
		if bone_name == fp_root_bone:
			root_id = idx
		
		if bone_name == fp_shoulder_bone:
			shoulders_id = idx
	
	get_parent().add_child_below_node($'../Model', viewmodel)


func _ready():
	
	if Engine.editor_hint: return
	
	
	if not has_meta('unique'):
		return
	
	_init_camera()
	_init_viewport()
	
	#yield(get_tree(), 'idle_frame')
	
	call_deferred('_init_fp_skeleton')
	call_deferred('_reset_viewport')


func _rotate_camera(delta_x, delta_y):
	
	camera.rotation.x += delta_x
	camera.rotation.y += delta_y


func _blend_fp_skeleton():
	
	var s_world = $'../Model'.get_child(0)
	var s_view = $'../ViewModel'.get_child(0)
	
	
	for idx in range(s_world.get_bone_count()):
		
		var bone_name = s_world.get_bone_name(idx)
		var p_world = s_world.get_bone_global_pose(idx)
		
		s_view.set_bone_global_pose(idx, p_world)
		
		if bone_name in fp_hidden_bones:
			p_world = s_world.get_bone_pose(idx)
			p_world.basis = p_world.basis.scaled(Vector3(0.01, 0.01, 0.01))
			s_view.set_bone_pose(idx, p_world)
	
	
	var pose_shoulders = s_view.get_bone_global_pose(shoulders_id).origin + fp_offset
	var shoulders_transform = owner.global_transform.basis.xform(pose_shoulders)
	var rig_transform = rig.global_transform.origin - owner.global_transform.origin
	
	s_view.global_transform.origin = owner.global_transform.origin + rig_transform - shoulders_transform


func _camera_follow_preview():
	
	var rig = $Container/Viewport/CameraRig
	
	if null in [owner, rig]: return
	
	rig.global_transform.origin = owner.global_transform.origin + owner.global_transform.basis.xform(rig_translation)
	
	rig.rotation_degrees = owner.rotation_degrees + rig_rotation_degrees


func _camera_follow_target():
	
	rig.global_transform.origin = owner.global_transform.origin + owner.global_transform.basis.xform(rig_translation)
	
	rig.rotation_degrees = owner.rotation_degrees + rig_rotation_degrees
	
	camera.rotation.x = clamp(camera.rotation.x, -cam_max_y, cam_max_y)
	camera.rotation.y = clamp(camera.rotation.y, -cam_max_x, cam_max_x)
	
	rig_translated = false
	rig_rotated = false


func _align_player_to_camera():
	
	var target = owner.global_transform.origin + camera.global_transform.basis.z#.inverse()
	target.y = owner.global_transform.origin.y
	owner.look_at(target, Vector3(0, 1, 0))


func _has_selection():
	
	return selection != null and selection.get('tags') != null and 'Item' in selection.tags


func _contain_selection():
	
	if _has_selection():
		
		var data = {
			'from': owner.get_path(),
			'to': selection.get_path()
			}
		
		LinkHub._create('Contains', data)


func _update_raycast_selection():
	
	var collider = raycast.get_collider()
	
	if selection != collider:
		selection = collider
		emit_signal('changed_selection', selection)


func _process(delta):
	
	if Engine.editor_hint: 
		_camera_follow_preview()
		return
	
	_camera_follow_target()
	_blend_fp_skeleton()
	_update_raycast_selection()
