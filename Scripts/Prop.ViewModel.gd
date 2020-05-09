extends Spatial

const viewmodel_offset = 5
const worldmodel_offset = 15

var has_skeleton = false

var hidden_bones = []
var follow_camera_bone_id
var follow_camera_offset = Vector3()

var model
var bone_name


func _init_duplicate_meshes():
	
	for w_child in model.get_children():
		
		w_child = w_child.duplicate()
		add_child(w_child)
		
		if w_child is Skeleton:
			
			for s_child in w_child.get_children():
				
				if s_child is MeshInstance:
					
					s_child.cast_shadow = 0
		
		elif w_child is MeshInstance:
			
			w_child.cast_shadow = 0


func _cull_mask_bits(world_mesh, view_mesh):
	
	var camera = $'../CameraRig/Camera'
	
	print(owner.name, ' ', owner.player_index)
	
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
	
	for w_child in model.get_children():
		
		if w_child is Skeleton:
			
			var vm_child = get_node(w_child.name)
			
			for s_child in w_child.get_children():
				
				if s_child is MeshInstance:
				
					var vs_child = vm_child.get_node(s_child.name)
					
					_cull_mask_bits(s_child, vs_child)
		
		if w_child is MeshInstance:
			
			var vm_child = get_node(w_child.name)
			
			_cull_mask_bits(w_child, vm_child)


func _blend_skeletons(s_world, s_view):
	
	var rig = $'../CameraRig'
	
	
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



func _ready():
	
	if owner == null:
		yield(get_tree(), 'idle_frame')
	
	
	_init_duplicate_meshes()
	
	owner.connect('player_index_changed', self, '_init_mesh_layers')
	
	yield(get_tree(), 'idle_frame')
	
	_init_mesh_layers()


func _process(delta):
	
	if get_child_count() == 0:
		return
	
	
	for w_child in model.get_children():
		
		if w_child is Skeleton:
			
			var vm_child = get_node(w_child.name)
			
			_blend_skeletons(w_child, vm_child)