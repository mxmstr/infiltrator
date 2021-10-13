extends "res://Scripts/Behavior.gd"

var oneshot
var action
var action_up
var action_down


func _set_layer(layer):
	
	if layer == Meta.BlendLayer.ACTION:
		set('parameters/Layer/current', 'Action')
		oneshot.filter_enabled = false
	
	if layer == Meta.BlendLayer.MIXED:
		set('parameters/Layer/current', 'Action')
		oneshot.filter_enabled = true
	
	if layer == Meta.BlendLayer.MOVEMENT:
		set('parameters/Layer/current', 'Movement')
		oneshot.filter_enabled = true


func _set_action_blend(blend):
	
	set('parameters/ActionBlend/blend_amount', blend)


func _set_animation(animation, scale, clip_start, clip_end):
	
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


func _set_oneshot_active(enabled):
	
	oneshot.active = enabled


func _ready():
	
	oneshot = tree_root.get_node('OneShot')
	action = tree_root.get_node('Action')
	action_up = tree_root.get_node('ActionUp')
	action_down = tree_root.get_node('ActionDown')
	
	emit_signal('action', 'Default', {})