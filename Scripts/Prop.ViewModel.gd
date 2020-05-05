extends Spatial

const viewmodel_offset = 5
const worldmodel_offset = 15

var hidden_bones = []
var follow_camera_bone_id
var follow_camera_offset = Vector3()

var model
var bone_name



func _set_mesh_layers():
	
	var camera = $'../CameraRig/Camera'
	var mesh = $'../Model'.get_child(0).get_child(0)
	var viewmesh = get_child(0).get_child(0)
	
	
	camera.set_cull_mask_bit(viewmodel_offset, false)
	viewmesh.set_layer_mask_bit(viewmodel_offset, false)
	
	camera.set_cull_mask_bit(worldmodel_offset, true)
	mesh.set_layer_mask_bit(worldmodel_offset, false)
	
	
	camera.set_cull_mask_bit(viewmodel_offset + get_parent().player_index, true)
	viewmesh.set_layer_mask_bit(0, false)
	viewmesh.set_layer_mask_bit(viewmodel_offset + get_parent().player_index, true)
	
	camera.set_cull_mask_bit(worldmodel_offset + get_parent().player_index, false)
	mesh.set_layer_mask_bit(0, false)
	mesh.set_layer_mask_bit(worldmodel_offset + get_parent().player_index, true)


func _ready():
	
	if owner == null:
		yield(get_tree(), 'idle_frame')
	
	
	var skeleton = model.get_child(0).duplicate()
	skeleton.get_child(0).cast_shadow = 0
	add_child(skeleton)
	
	_set_mesh_layers()
	
	owner.connect('player_index_changed', self, '_set_mesh_layers')


func _process(delta):
	
	if get_child_count() == 0:
		return
	
	var rig = $'../CameraRig'
	var s_world = model.get_child(0)
	var s_view = get_child(0)
	
	
	for idx in range(s_world.get_bone_count()):
		
		var s_world_bone_name = s_world.get_bone_name(idx)
		var p_world = s_world.get_bone_global_pose(idx)
		
		s_view.set_bone_global_pose(idx, p_world)
		
		if bone_name in hidden_bones:
			p_world = s_world.get_bone_pose(idx)
			p_world.basis = p_world.basis.scaled(Vector3(0.01, 0.01, 0.01))
			s_view.set_bone_pose(idx, p_world)
	
	
	if follow_camera_bone_id != null:
		
		var pose_bone = s_view.get_bone_global_pose(follow_camera_bone_id).origin + follow_camera_offset
		var bone_transform = owner.global_transform.basis.xform(pose_bone)
		var rig_transform = rig.global_transform.origin - owner.global_transform.origin
		
		s_view.global_transform.origin = owner.global_transform.origin + rig_transform - bone_transform
