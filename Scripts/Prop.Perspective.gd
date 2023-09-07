extends SubViewportContainer

@export var mouse_device = -1
@export var keyboard_device = -1
@export var gamepad_device = -1
@export var fp_offset = Vector3(0, 0, 0)
@export var fp_root_bone: String
@export var fp_shoulder_bone: String
@export var fp_hidden_bones :Array[String] = []

var viewmodel_property = preload('res://Scenes/Components/Properties/ViewModel.property.tscn')

var fp_skeleton_offset_enable = true
var viewmodels = []
var viewmodel_offset = 5
var worldmodel_offset = 15
var rig_translated = false
var rig_rotated = false

@onready var model = $'../Model'
@onready var mesh = $'../Model'.get_child(0).get_child(0)
@onready var right_hand = $'../RightHandContainer'
@onready var left_hand = $'../LeftHandContainer'
@onready var viewport = get_node('Viewport2D')
@onready var ui = get_node('../UI')
@onready var rig = get_node_or_null('../CameraRig')
@onready var camera = rig.get_node('Camera3D')


func _on_pre_draw(viewport_rid):
	
	return
	if viewport_rid.get_id() == viewport.get_viewport_rid().get_id():
		
		for idx in range(model.get_child(0).get_bone_count()):
			
			var s_world_bone_name = model.get_child(0).get_bone_name(idx)
			
			if s_world_bone_name in ['Head', 'Neck']:
				
#				var global_pose = model.get_child(0).get_bone_global_pose_no_override(idx)
#				global_pose.basis = global_pose.basis.scaled(Vector3(0.01, 0.01, 0.01))
#				model.get_child(0).set_bone_global_pose_override(idx, global_pose, 1.0, true)
				
				var p_world = model.get_child(0).get_bone_pose(idx)
				p_world.basis = p_world.basis.scaled(Vector3(0.01, 0.01, 0.01))
				model.get_child(0).set_bone_pose(idx, p_world)
#				prints(model.get_child(0).get_bone_pose(idx).basis.get_scale())


func _on_post_draw(viewport_rid):
	
	return
	if viewport_rid.get_id() == viewport.get_viewport_rid().get_id():
		
		for idx in range(model.get_child(0).get_bone_count()):
			
			var s_world_bone_name = model.get_child(0).get_bone_name(idx)
			
			if s_world_bone_name in ['Head', 'Neck']:
				
				var p_world = model.get_child(0).get_bone_pose(idx)
				p_world.basis = p_world.basis.scaled(Vector3(0.01, 0.01, 0.01))
				model.get_child(0).set_bone_pose(idx, p_world)


func _on_item_contained(item, container):
	
	if container.bone_name != '':
		
		var viewmodel = viewmodel_property.instantiate()
		var contains_link = preload('res://Scripts/Link.Contains.gd')
		viewmodel.name = item.base_name + 'ViewModel'
		viewmodel.actor = item
		viewmodel.container = container
		
		owner.add_child(viewmodel)
		viewmodel.set_owner(owner)
		
		viewmodels.append(viewmodel)


func _on_item_released(item, container):
	
	for viewmodel in viewmodels.duplicate():
		if viewmodel.actor == item:
			viewmodel._destroy()
			viewmodels.erase(viewmodel)


func _init_fp_skeleton():
	
	if model == null:
		return
	
	
	var root_id
	var shoulders_id
	
	for idx in range(model.get_child(0).get_bone_count()):
		
		var bone_name = model.get_child(0).get_bone_name(idx)
		
		if bone_name == fp_root_bone:
			root_id = idx
		
		if bone_name == fp_shoulder_bone:
			shoulders_id = idx
	
	
	var viewmodel = viewmodel_property.instantiate()
	viewmodel.name = 'ActorViewModel'
	viewmodel.actor = owner
	viewmodel.hidden_bones = fp_hidden_bones
	viewmodel.follow_camera_bone_id = shoulders_id
	viewmodel.follow_camera_offset = fp_offset
	
	owner.add_child(viewmodel)
	viewmodel.set_owner(owner)
	
	viewmodels.append(viewmodel)
	
	right_hand.connect('item_added',Callable(self,'_on_item_contained').bind(right_hand))
	right_hand.connect('item_removed',Callable(self,'_on_item_released').bind(right_hand))
	left_hand.connect('item_added',Callable(self,'_on_item_contained').bind(left_hand))
	left_hand.connect('item_removed',Callable(self,'_on_item_released').bind(left_hand))


func _init_viewport():
	
	var render_width = owner.get_viewport().size.x
	var render_height = owner.get_viewport().size.y
	var window_width = ProjectSettings.get_setting('display/window/size/viewport_width')
	var window_height = ProjectSettings.get_setting('display/window/size/viewport_height')
	var render_scale = ProjectSettings.get_setting('rendering/quality/filters/render_scale')
	
#	prints(window_width
	
	if Meta.player_count == 1:
		return
	
	if Meta.player_count > 2:
		
		if owner.player_index in [0, 2]:
			ui.position.x = 0
			position.x = 0
		else:
			ui.position.x = window_width / 2
			position.x = window_width / 2

		if owner.player_index in [0, 1]:
			ui.position.y = 0
			position.y = 0
		else:
			ui.position.y = window_height / 2
			position.y = window_height / 2
		
		ui.get_node('SubViewport/Control').size.x =  window_width / 2
		ui.get_node('SubViewport/Control').size.y = window_height / 2
		size.x = window_width / 2
		size.y = window_height / 2
		viewport.size.x = render_width / 2
		viewport.size.y = render_height / 2
		viewport.size *= render_scale

	else:
		
		if owner.player_index == 0:
			ui.position.y = 0
			position.y = 0
		else:
			ui.position.y = window_height / 2
			position.y = window_height / 2

		ui.get_node('SubViewport/Control').size.x = window_width
		ui.get_node('SubViewport/Control').size.y = window_height / 2
		size.x = window_width
		size.y = window_height / 2
		viewport.size.x = render_width
		viewport.size.y = render_height / 2
		viewport.size *= render_scale
	
	
#	for child in owner.get_children():
#
#		var script_name = child.get_script().get_path().get_file() if child.get_script() != null else ''
#
#		if script_name == 'Prop.Container.gd' and child.bone_name != '':
#
#			child.connect('item_added',Callable(self,'_on_item_contained'))
#			child.connect('item_removed',Callable(self,'_on_item_released'))


func _ready():
	
#	RenderingServer.connect('viewport_pre_draw',Callable(self,'_on_pre_draw'))
#	RenderingServer.connect('viewport_post_draw',Callable(self,'_on_post_draw'))
	
	await get_tree().process_frame
	
	_init_fp_skeleton()
	_init_viewport()
	
	get_tree().root.connect('size_changed',Callable(self,'_init_viewport'))


#func _process(delta):
#
#
#	for idx in range(model.get_child(0).get_bone_count()):
#
#		var s_world_bone_name = model.get_child(0).get_bone_name(idx)
#
#		if s_world_bone_name in ['Head', 'Neck']:
#
#			var p_world = model.get_child(0).get_bone_pose(idx)
#			p_world.basis = p_world.basis.scaled(Vector3(0.01, 0.01, 0.01))
#			model.get_child(0).set_bone_pose(idx, p_world)
