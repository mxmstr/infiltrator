#tool
extends 'res://Scripts/AnimationTree.gd'

export var mouse_device = -1
export var keyboard_device = -1
export var fp_offset = Vector3(0, 0, 0.1)
export(String) var fp_root_bone
export(String) var fp_shoulder_bone
export(Array, String) var fp_hidden_bones

var player_index = 0
var viewmodel_offset = 5
var worldmodel_offset = 15

var root_id
var shoulders_id

var rig_translated = false
var rig_rotated = false

onready var rig = $'../CameraRig'
onready var camera = rig.get_node('Camera')


func _reset_viewport():
	
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


#func _contain_selection():
#
#	if selection != null:
#
#		var data = {
#			'from': owner.get_path(),
#			'to': selection.get_path()
#			}
#
#		LinkHub._create('Contains', data)


func _ready():
	
	if Engine.editor_hint: return
	
	if not has_meta('unique'):
		return
	
	_init_viewport()
	
	$'../CameraRaycast'.connect('selection_changed', self, '_on_selection_changed')
	
	yield(get_tree(), 'idle_frame')
	
	_init_fp_skeleton()
	_reset_viewport()


func _process(delta):
	
	_blend_fp_skeleton()
