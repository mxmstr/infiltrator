extends AnimationTree

export(String) var root_bone
export(Array, String) var movement_bones
export(Array, String) var fp_hidden_bones

var cached_pose = []


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
	
	active = true


func _sync_blend_spaces():
	
	var velocity = $'../../HumanMovement'.velocity
	velocity.y = 0
	
	var local_velocity = $'../../'.global_transform.basis.xform_inv(velocity)
	local_velocity = local_velocity / $'../../HumanMovement'.max_speed
	
	set('parameters/Grounded/blend_position', Vector2(-local_velocity.x, local_velocity.z))


func _blend_skeletons():
	
	var s_movement = $AnimationPlayer.get_node($AnimationPlayer.root_node)
	var s_action = $'../AnimationPlayer'.get_node($'../AnimationPlayer'.root_node)
	var layered = get_parent().blend_mode == Infiltrator.blend.LAYERED
	var action_only = get_parent().blend_mode == Infiltrator.blend.ACTION
	var movement_only = get_parent().blend_mode == Infiltrator.blend.MOVEMENT
	
	for idx in range(s_action.get_bone_count()):
		cached_pose.append(s_action.get_bone_global_pose(idx))
	
	
	for idx in range(s_action.get_bone_count()):
		var bone_name = s_action.get_bone_name(idx)
		var move_transform = s_movement.get_bone_global_pose(idx)
		var action_transform = s_action.get_bone_global_pose(idx)
		
		
		if not action_only:
		
			if movement_only or bone_name in movement_bones:
				if bone_name == root_bone:
					action_transform = move_transform
				else:
					action_transform.basis = move_transform.basis
				s_action.set_bone_global_pose(idx, action_transform)
			
			else:
				action_transform.basis = cached_pose[idx].basis
				s_action.set_bone_global_pose(idx, action_transform)
		
		
		if bone_name in fp_hidden_bones:
			action_transform.basis = action_transform.basis.scaled(Vector3(0.01, 0.01, 0.01))
			
			s_action.set_bone_global_pose(idx, action_transform)


func _process(delta):
	
	_sync_blend_spaces()
	_blend_skeletons()
	