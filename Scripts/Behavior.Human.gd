extends "res://Scripts/Behavior.gd"

export(String) var root_bone
export(Array, String) var action_bones

var skeleton
var oneshot
var action
var action_up
var action_down
var layer = Meta.BlendLayer.MOVEMENT
var next = 'Default'
var switch_mode = 'Immediate'
var cached_action_pose

onready var movement = get_node_or_null('../Movement')

signal on_process


func _on_action_finished():
	
#	prints('finished', action.animation, next)

	if action.animation == 'Default':
		return

	call_deferred('emit_signal', 'action', next, {})


func _can_switch():
	
	return switch_mode == 'Immediate' or not _is_oneshot_active()


func _set_layer(_layer):
	
	layer = _layer


func _set_action_blend(blend):
	
	set('parameters/ActionBlend/blend_amount', blend)


func _set_animation(animation, scale, clip_start, clip_end):
	
#	prints(animation, scale, clip_start, clip_end)
	
	action.scale = scale
	action.clip_start = clip_start
	action.clip_end = clip_end
	action.animation = animation


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


func _is_oneshot_active():
	
	return get('parameters/OneShot/active')


func _set_oneshot_active(enabled):
	
	set('parameters/OneShot/active', enabled)


func _play(new_state, animation, attributes, up_animation=null, down_animation=null):
	
	if not _can_switch():
		return
	
	current_state = new_state
	
	_set_oneshot_active(false)
	advance(0)
	
	
	var scale = 1.0
	var clip_start = 0
	var clip_end = 0
	next = 'Default'
	
	if attributes.has('layer'):
		_set_layer(Meta.BlendLayer[attributes.layer])
	
	if attributes.has('speed'):
		scale = attributes.speed
	
	if attributes.has('clip_start'):
		clip_start = attributes.clip_start
	
	if attributes.has('clip_end'):
		clip_end = attributes.clip_end
	
	if attributes.has('next'):
		next = attributes.next
	
	if attributes.has('switch_mode'):
		switch_mode = attributes.switch_mode
	
	_set_animation(animation, scale, clip_start, clip_end)
	
	if up_animation:
		_set_animation_up(up_animation, scale, clip_start, clip_end)
	
	if down_animation:
		_set_animation_down(down_animation, scale, clip_start, clip_end)
	
	
	if current_state == 'Default':
		return
	
	_set_oneshot_active(true)


func _cache_action_pose():
	
	cached_action_pose = []
	
	for idx in range(skeleton.get_bone_count()):
		
		var bone_name = skeleton.get_bone_name(idx)
		
		if bone_name == root_bone:
			cached_action_pose.append(skeleton.get_bone_global_pose(idx))
		else:
			cached_action_pose.append(skeleton.get_bone_pose(idx))


func _apply_action_pose():
	
	for idx in range(skeleton.get_bone_count()):
		
		var bone_name = skeleton.get_bone_name(idx)
		
		if bone_name == root_bone:
			
			cached_action_pose[idx].origin = skeleton.get_bone_global_pose(idx).origin
			skeleton.set_bone_global_pose(idx, cached_action_pose[idx])
			
		elif bone_name in action_bones:
			
			skeleton.set_bone_pose(idx, cached_action_pose[idx])


func _ready():
	
	skeleton = $AnimationPlayer.get_node($AnimationPlayer.root_node)
	oneshot = tree_root.get_node('OneShot')
	action = tree_root.get_node('Action')
	action_up = tree_root.get_node('ActionUp')
	action_down = tree_root.get_node('ActionDown')
	
#	tree_root.get_node('Movement')._ready(self, null, 'parameters/', 'root')
	
	$Movement.tree_root._ready(self, null, 'parameters/', 'root')
#	$Movement.tree_root.set_filter_path('.:Pelvis', true)
	
	oneshot.connect('finished', self, '_on_action_finished')
	
	emit_signal('action', next, {})


func _process(delta):
	
	oneshot.filter_enabled = layer == Meta.BlendLayer.MIXED
	
	if layer != Meta.BlendLayer.MOVEMENT:
		
		advance(delta)
		_cache_action_pose()
	
	if layer != Meta.BlendLayer.ACTION:
		$Movement.advance(delta)
	
	if layer != Meta.BlendLayer.MOVEMENT:
		_apply_action_pose()
	
	if owner.name == 'Anderson':
		movement._apply_root_transform(get_root_motion_transform())