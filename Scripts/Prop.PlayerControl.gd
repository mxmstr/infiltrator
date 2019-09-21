extends ViewportContainer

export var mouse_device = -1
export var keyboard_device = -1
export(Array, String) var fp_hidden_bones

var player_index = 0
var viewmodel_offset = 5
var worldmodel_offset = 15


func _reset_viewport():
	
	var camera = $Viewport/Camera
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


func _ready():
	
	var viewmodel = $'../Model'.duplicate()
	viewmodel.name = 'ViewModel'
	get_parent().call_deferred('add_child_below_node', $'../Model', viewmodel)
	
	yield(get_tree(), 'idle_frame')
	
	_reset_viewport()


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


func _process(delta):
	
	_blend_fp_skeleton()