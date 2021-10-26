extends Spatial

const viewmodel_offset = 5
const worldmodel_offset = 15

var has_skeleton = false

var hidden_bones = []
var hidden_bone_ids = []
var follow_camera_bone_id
var follow_camera_offset = Vector3()

var model
var container
var container_root
var item_position_offset
var item_rotation_offset
var world_skeleton
var vm_skeleton

onready var contains_link = load('res://Scripts/Link.Contains.gd')
onready var behavior = get_node_or_null('../Behavior')
onready var camera_rig = $'../CameraRig'
onready var camera = $'../CameraRig/Camera'


func _init_duplicate_meshes():
	
	transform = model.transform
	
	var viewmodel = world_skeleton.duplicate()
	
	for child in viewmodel.get_children():
		
		if child is MeshInstance:
			child.cast_shadow = 0
		else:
			child.queue_free()
	
	add_child(viewmodel)


func _cull_mask_bits(world_mesh, view_mesh):
	
	camera.set_cull_mask_bit(viewmodel_offset, false)
	view_mesh.set_layer_mask_bit(viewmodel_offset, false)
	
	camera.set_cull_mask_bit(worldmodel_offset, true)
	world_mesh.set_layer_mask_bit(worldmodel_offset, false)
	
	
	# Make my camera render only the viewmodel
	camera.set_cull_mask_bit(viewmodel_offset + owner.player_index, true)
	view_mesh.set_layer_mask_bit(0, false)
	view_mesh.set_layer_mask_bit(viewmodel_offset + owner.player_index, true)
	
	camera.set_cull_mask_bit(worldmodel_offset + owner.player_index, false)
	world_mesh.set_layer_mask_bit(0, false)
	world_mesh.set_layer_mask_bit(worldmodel_offset + owner.player_index, true)


func _init_mesh_layers():
	
	for w_child in world_skeleton.get_children():
		
		if not w_child is MeshInstance:
			continue
		
		var path_to_child = model.get_path_to(w_child)
		var vm_child = get_node(path_to_child)
		
		_cull_mask_bits(w_child, vm_child)


func _uncull_mask_bits(world_mesh, view_mesh):
	
	world_mesh.set_layer_mask_bit(0, true)
	world_mesh.set_layer_mask_bit(worldmodel_offset + get_parent().player_index, false)


func _revert_mesh_layers():
	
	for w_child in world_skeleton.get_children():
		
		if not w_child is MeshInstance:
			continue
		
		var path_to_child = model.get_path_to(w_child)
		var vm_child = get_node(path_to_child)
		
		_uncull_mask_bits(w_child, vm_child)


func _init_container():
	
	if not container:
		return
	
	if not container_root:
		container_root = container.root
	
	container_root.translation = container.position_offset
	container_root.rotation_degrees = container.rotation_degrees_offset
	
	item_position_offset = _get_item_position_offset(model.owner)
	item_rotation_offset = _get_item_rotation_offset(model.owner)


func _blend_skeletons(s_world, s_view):
	
#	behavior.blend_with_skeleton(s_view, '', [])
#
#	for idx in hidden_bone_ids:
#
#		var p_world = s_world.get_bone_pose(idx)
#		p_world.basis = p_world.basis.scaled(Vector3(0.01, 0.01, 0.01))
#		s_view.set_bone_pose(idx, p_world)
	
	for idx in range(s_world.get_bone_count()):

		var s_world_bone_name = s_world.get_bone_name(idx)
		var p_world = s_world.get_bone_pose(idx)

		s_view.set_bone_pose(idx, p_world)

		if s_world_bone_name in hidden_bones:
			p_world = s_world.get_bone_pose(idx)
			p_world.basis = p_world.basis.scaled(Vector3(0.01, 0.01, 0.01))
			s_view.set_bone_pose(idx, p_world)
	
	
	s_view.transform = s_world.transform


#	if follow_camera_bone_id:
#
#		var pose_bone = s_view.get_bone_global_pose(follow_camera_bone_id).origin + follow_camera_offset
#		var bone_transform = owner.global_transform.basis.xform(pose_bone)
#		var rig_transform = camera_rig.global_transform.origin - owner.global_transform.origin
#
#		s_view.global_transform.origin = owner.global_transform.origin + rig_transform - bone_transform


func _get_item_position_offset(item):
	
	if item._has_tag('Offset-position'):
		
		var item_data = item._get_tag('Offset-position')
		
		var item_parent_name = item_data[0]
		var item_bone_name = item_data[1]
		var item_offset = item_data[2].split(',')
		
		return Vector3(float(item_offset[0]), float(item_offset[1]), float(item_offset[2])) if (
			(item_parent_name == '' or container_root.get_parent().name == item_parent_name) and \
			(item_bone_name == '' or item_bone_name == container.bone_name)
			) else Vector3()
	
	return Vector3()


func _get_item_rotation_offset(item):
	
	if item._has_tag('Offset-rotation'):
		
		var item_data = item._get_tag('Offset-rotation')
		
		var item_parent_name = item_data[0]
		var item_bone_name = item_data[1]
		var item_offset = item_data[2].split(',')
		
		return Vector3(deg2rad(float(item_offset[0])), deg2rad(float(item_offset[1])), deg2rad(float(item_offset[2]))) if (
			(item_parent_name == '' or container_root.get_parent().name == item_parent_name) and \
			(item_bone_name == '' or item_bone_name == container.bone_name)
			) else Vector3()
	
	return Vector3()


func _enter_tree():
	
#	if model.get_child(0) is Skeleton:
	
	world_skeleton = model.get_child(0)
	
	for idx in range(world_skeleton.get_bone_count()):
		if world_skeleton.get_bone_name(idx) in hidden_bones:
			hidden_bone_ids.append(idx)
	
	_init_duplicate_meshes()
	
	vm_skeleton = get_child(0)


func _ready():
	
	if not owner:
		yield(get_tree(), 'idle_frame')
	
	owner.connect('player_index_changed', self, '_init_mesh_layers')
	
	yield(get_tree(), 'idle_frame')
	
	_init_mesh_layers()
	_init_container()


func _exit_tree():
	
	_revert_mesh_layers()


func _process(delta):
	
	if not get_child_count():
		return
#
#
#	if container_root != null:
#
#		global_transform = container_root.global_transform.translated(item_position_offset)
#
#		global_transform.basis = container_root.global_transform.basis
#		global_transform.basis = global_transform.basis.rotated(global_transform.basis.x, item_rotation_offset.x)
#		global_transform.basis = global_transform.basis.rotated(global_transform.basis.y, item_rotation_offset.y)
#		global_transform.basis = global_transform.basis.rotated(global_transform.basis.z, item_rotation_offset.z)
#
#
	_blend_skeletons(world_skeleton, vm_skeleton)
#
#	rotation = model.rotation
