extends AnimationTree

export(String) var root_bone
export(Array, String) var bones


func _set_bone_y_rotation(bone_name, y_rot, root=false):
	
	var s_action = $AnimationPlayer.get_node($AnimationPlayer.root_node)
	
	
	var bone = s_action.find_bone(bone_name)
	var bone_transform = s_action.get_bone_rest(bone) if root else s_action.get_bone_global_pose(bone)
	var rotate_amnt = y_rot - s_action.global_transform.basis.get_euler().y
	bone_transform = bone_transform.rotated(Vector3(0, 1, 0), rotate_amnt)
	s_action.set_bone_global_pose(bone, bone_transform)


func _ready():

	var skeleton = $'../../Model'.get_children()[0].duplicate()

	for child in skeleton.get_children():
		child.queue_free()

	$AnimationPlayer.add_child(skeleton)
	$AnimationPlayer.root_node = NodePath(skeleton.name)
	
	#anim_player = NodePath('AnimationPlayer')
	tree_root.set_start_node('Run')
	
	active = true


func _process(delta):
	
	var s_movement = $AnimationPlayer.get_node($AnimationPlayer.root_node)
	var s_action = $'../AnimationPlayer'.get_node($'../AnimationPlayer'.root_node)
	
	var cached_pose = []
	for idx in range(s_action.get_bone_count()):
		cached_pose.append(s_action.get_bone_global_pose(idx).basis)
	
	
	for bone_name in bones:
		var bone_id = s_movement.find_bone(bone_name)
		var move_transform = s_movement.get_bone_global_pose(bone_id)#s_movement.get_bone_rest(bone_id) if bone_name == root_bone else s_movement.get_bone_global_pose(bone_id)
		var action_transform = s_action.get_bone_global_pose(bone_id)#s_action.get_bone_rest(bone_id) if bone_name == root_bone else s_action.get_bone_global_pose(bone_id)
		
		#action_transform.basis = move_transform.basis

		s_action.set_bone_global_pose(bone_id, move_transform)
	
	
	for idx in range(s_action.get_bone_count()):
		var bone_name = s_action.get_bone_name(idx)
		
		if not bone_name in bones:
			var action_transform = s_action.get_bone_global_pose(idx)
			action_transform.basis = cached_pose[idx]
			s_action.set_bone_global_pose(idx, action_transform)