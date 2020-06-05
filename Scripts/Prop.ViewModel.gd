extends Spatial

const viewmodel_offset = 5
const worldmodel_offset = 15

var has_skeleton = false

var hidden_bones = []
var follow_camera_bone_id
var follow_camera_offset = Vector3()

var model
var container
var container_root
var container_bone_name


func _init_duplicate_meshes():
	
	var viewmodel = model.duplicate()
	add_child(viewmodel)
	
	for w_child in Meta._get_children_recursive(viewmodel):
		
		if w_child is MeshInstance:
			
			w_child.cast_shadow = 0


func _cull_mask_bits(world_mesh, view_mesh):
	
	var camera = $'../CameraRig/Camera'
	
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
	
	for w_child in Meta._get_children_recursive(model):
		
		var path_to_child = model.get_path_to(w_child)
		var vm_child = get_node('Model/' + path_to_child)
		
		if w_child is MeshInstance:
			
			_cull_mask_bits(w_child, vm_child)


func _uncull_mask_bits(world_mesh, view_mesh):
	
	var camera = $'../CameraRig/Camera'
	
	world_mesh.set_layer_mask_bit(0, true)
	world_mesh.set_layer_mask_bit(worldmodel_offset + get_parent().player_index, false)


func _revert_mesh_layers():
	
	for w_child in Meta._get_children_recursive(model):
		
		var path_to_child = model.get_path_to(w_child)
		var vm_child = get_node('Model/' + path_to_child)
		
		if w_child is MeshInstance:
			
			_uncull_mask_bits(w_child, vm_child)


func _init_container():
	
	if container == null:
		return
	
	if container_root == null:
		container_root = container.root
	
	container_root.translation = container.position_offset
	container_root.rotation_degrees = container.rotation_degrees_offset


func _blend_skeletons(s_world, s_view):
	
	var rig = $'../CameraRig'
	
	
	for idx in range(s_world.get_bone_count()):
		
		var s_world_bone_name = s_world.get_bone_name(idx)
		var p_world = s_world.get_bone_global_pose(idx)
		
		s_view.set_bone_global_pose(idx, p_world)
		
		if s_world_bone_name in hidden_bones:
			p_world = s_world.get_bone_pose(idx)
			p_world.basis = p_world.basis.scaled(Vector3(0.01, 0.01, 0.01))
			s_view.set_bone_pose(idx, p_world)
	
	
	if follow_camera_bone_id != null:
		
		var pose_bone = s_view.get_bone_global_pose(follow_camera_bone_id).origin + follow_camera_offset
		var bone_transform = owner.global_transform.basis.xform(pose_bone)
		var rig_transform = rig.global_transform.origin - owner.global_transform.origin
		
		s_view.global_transform.origin = owner.global_transform.origin + rig_transform - bone_transform


func _ready():
	
	if owner == null:
		yield(get_tree(), 'idle_frame')
	
	
	_init_duplicate_meshes()
	
	owner.connect('player_index_changed', self, '_init_mesh_layers')
	
	yield(get_tree(), 'idle_frame')
	
	_init_mesh_layers()
	_init_container()


func _exit_tree():
	
	_revert_mesh_layers()


func _process(delta):
	
	if get_child_count() == 0:
		return
	
	
	if container_root != null:
		
		var item_position_offset = container._get_item_position_offset(model.owner)
		var item_rotation_offset = container._get_item_rotation_offset(model.owner)
		
		global_transform = container_root.global_transform.translated(item_position_offset)
		
		global_transform.basis = container_root.global_transform.basis
		global_transform.basis = global_transform.basis.rotated(global_transform.basis.x, item_rotation_offset.x)
		#global_transform.basis = global_transform.basis.rotated(global_transform.basis.x, model.rotation.x)
		global_transform.basis = global_transform.basis.rotated(global_transform.basis.y, item_rotation_offset.y)
		#global_transform.basis = global_transform.basis.rotated(global_transform.basis.y, model.rotation.y)
		global_transform.basis = global_transform.basis.rotated(global_transform.basis.z, item_rotation_offset.z)
		#global_transform.basis = global_transform.basis.rotated(global_transform.basis.z, model.rotation.z)
		
		#global_transform = global_transform.translated(model.translation)
	
	
	for w_child in Meta._get_children_recursive(model):
		
		var path_to_child = model.get_path_to(w_child)
		var vm_child = get_node('Model/' + path_to_child)
		
		if w_child is Skeleton:
			
			_blend_skeletons(w_child, vm_child)
	