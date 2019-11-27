extends 'res://Scripts/StateMachine.gd'

export var mouse_device = -1
export var keyboard_device = -1
export(Array, String) var fp_hidden_bones

export var cam_max_x = 0.0
export var cam_max_y = PI / 2

var player_index = 0
var viewmodel_offset = 5
var worldmodel_offset = 15

var selection
var last_selection

onready var rig = $Container/Viewport/CameraRig
onready var camera = $Container/Viewport/CameraRig/Camera
onready var raycast = $Container/Viewport/CameraRig/Camera/RayCast

signal changed_selection


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
	
	get_parent().add_child_below_node($'../Model', viewmodel)


func _ready():
	
	if not has_meta('unique'):
		return
	
	_init_camera()
	_init_viewport()
	
	#yield(get_tree(), 'idle_frame')
	
	call_deferred('_init_fp_skeleton')
	call_deferred('_reset_viewport')


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


func _camera_follow_target():
	
	rig.global_transform.origin = owner.global_transform.basis.xform(rig.global_transform.origin)
	rig.global_transform.origin += owner.global_transform.origin
	
	rig.global_transform.basis *= owner.global_transform.basis
	
	#print([camera.rotation.y, -cam_max_x])
	camera.rotation.x = clamp(camera.rotation.x, -cam_max_y, cam_max_y)
	camera.rotation.y = clamp(camera.rotation.y, -cam_max_x, cam_max_x)


func _has_selection():
	
	return selection != null and selection.has_node('Behavior')


func _contain_selection():
	
	if _has_selection():
	
		var data = {
			'from': owner.get_path(),
			'to': selection.get_path()
			}
		
		$'/root/Game/Links'._establish_link('Contains', data)


func _update_raycast_selection():
	
	var collider = raycast.get_collider()
	
	if selection != collider:
		selection = collider
		emit_signal('changed_selection', selection)


func _process(delta):
	
	_blend_fp_skeleton()
	_camera_follow_target()
	_update_raycast_selection()