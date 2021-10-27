extends "res://Scripts/Behavior.gd"

export(String) var root_bone
export(Array, String) var action_bones

var layer = Meta.BlendLayer.MOVEMENT
var cached_action_pose

var action_up
var action_down

onready var movement = get_node_or_null('../Movement')
onready var anim_layer_movement = get_node_or_null('../AnimLayerMovement')

signal pre_advance


func _can_switch():
	
	return switch_mode == 'Immediate' or not _is_oneshot_active()


func _set_layer(_layer):
	
	layer = _layer


func _set_action_blend(blend):
	
	set('parameters/ActionBlend/blend_amount', blend)


func _set_animation_up(animation, scale, clip_start, clip_end):
	
	action_up.scale = scale
	action_up.clip_start = clip_start
	action_up.clip_end = clip_end
	action_up.animation = animation


func _set_animation_down(animation, scale, clip_start, clip_end):
	
	action_down.scale = scale
	action_down.clip_start = clip_start
	action_down.clip_end = clip_end
	action_down.animation = animation


func _cache_action_pose():
	
	cached_action_pose = []
	
	for idx in range(skeleton.get_bone_count()):
		
		var bone_name = skeleton.get_bone_name(idx)
		
		if bone_name == root_bone:
			cached_action_pose.append(skeleton.get_bone_global_pose(idx))
		else:
			cached_action_pose.append(skeleton.get_bone_pose(idx))



func _play(new_state, animation, attributes, up_animation=null, down_animation=null):
	
	if not _can_switch():
		return
	
	._play(new_state, animation, attributes)
	
	if attributes.has('layer'):
		_set_layer(Meta.BlendLayer[attributes.layer])
	
	_set_action_blend(0)
	
	if up_animation:
		_set_animation_up(up_animation, action.scale, action.clip_start, action.clip_end)
	else:
		_set_animation_up('DefaultAnim', action.scale, action.clip_start, action.clip_end)
	
	if down_animation:
		_set_animation_down(down_animation, action.scale, action.clip_start, action.clip_end)
	else:
		_set_animation_down('DefaultAnim', action.scale, action.clip_start, action.clip_end)


func _apply_action_pose():
	
	for idx in range(skeleton.get_bone_count()):
		
		var bone_name = skeleton.get_bone_name(idx)
		
		if bone_name == root_bone:
			
			cached_action_pose[idx].origin = skeleton.get_bone_global_pose(idx).origin
			skeleton.set_bone_global_pose(idx, cached_action_pose[idx])
			
		elif bone_name in action_bones:
			
			skeleton.set_bone_pose(idx, cached_action_pose[idx])


func _ready():
	
	action_up = tree_root.get_node('ActionUp')
	action_down = tree_root.get_node('ActionDown')
	
	anim_layer_movement.anim_player = anim_layer_movement.get_path_to($AnimationPlayer)
	anim_layer_movement.tree_root = anim_layer_movement.tree_root.duplicate(true)
	anim_layer_movement.tree_root._ready(anim_layer_movement, null, 'parameters/', 'root')
	anim_layer_movement.active = true


func _process(delta):
	
	emit_signal('pre_advance')
	
	oneshot.filter_enabled = layer == Meta.BlendLayer.MIXED
	
	if layer != Meta.BlendLayer.MOVEMENT:
		
		advance(delta)
		_cache_action_pose()

	if layer != Meta.BlendLayer.ACTION:
		anim_layer_movement.advance(delta)

	if layer != Meta.BlendLayer.MOVEMENT:
		_apply_action_pose()

	movement._apply_root_transform(get_root_motion_transform())
	
#	if owner.name == 'Anderson':
#		print(actionup)
	skeleton.scale = Vector3(-1, -1, -1)