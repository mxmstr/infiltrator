extends ViewportContainer

export var mouse_device = -1
export var keyboard_device = -1
export var gamepad_device = -1
export var fp_offset = Vector3(0, 0, 0)
export(String) var fp_root_bone
export(String) var fp_shoulder_bone
export(Array, String) var fp_hidden_bones

var viewmodel_property = preload('res://Scenes/Components/Properties/ViewModel.property.tscn')

var viewmodel
var viewmodel_offset = 5
var worldmodel_offset = 15

var rig_translated = false
var rig_rotated = false

onready var viewport = get_node('Viewport2D')
onready var ui = get_node('../UI')
onready var rig = get_node_or_null('../CameraRig')
onready var camera = rig.get_node('Camera')


func _on_pre_draw(viewport):
	
	pass


func _on_post_draw(viewport):
	
	pass


func _on_item_contained(container, item):
	
	if container.bone_name != '':
		
		var viewmodel = preload('res://Scenes/Components/Properties/ViewModel.property.tscn').instance()
		viewmodel.name = item.name + 'ViewModel'
		viewmodel.model = item.get_node('Model')
		viewmodel.container = container
		
		var path_to_root = $'../Model'.get_path_to(container.root)
		viewmodel.container_root = $'../ActorViewModel'.get_node('Model/' + path_to_root)
		
		owner.add_child(viewmodel)
		viewmodel.owner = owner


func _on_item_released(container, item):
	
	owner.get_node(item.name + 'ViewModel').queue_free()


func _init_fp_skeleton():
	
	if not has_node('../Model'):
		return
	
	
	var root_id
	var shoulders_id
	
	for idx in range($'../Model'.get_child(0).get_bone_count()):
		
		var bone_name = $'../Model'.get_child(0).get_bone_name(idx)
		
		if bone_name == fp_root_bone:
			root_id = idx
		
		if bone_name == fp_shoulder_bone:
			shoulders_id = idx
	
	
	viewmodel = viewmodel_property.instance()
	viewmodel.name = 'ActorViewModel'
	viewmodel.model = $'../Model'
	viewmodel.hidden_bones = fp_hidden_bones
	viewmodel.follow_camera_bone_id = shoulders_id
	viewmodel.follow_camera_offset = fp_offset
	
	owner.call_deferred('add_child', viewmodel)
	viewmodel.call_deferred('set_owner', owner)


func _init_viewport():
	
	var render_width = owner.get_viewport().size.x
	var render_height = owner.get_viewport().size.y
	var window_width = ProjectSettings.get_setting('display/window/size/width')
	var window_height = ProjectSettings.get_setting('display/window/size/height')
	var render_scale = ProjectSettings.get_setting('rendering/quality/filters/render_scale')
	
	if Meta.player_count > 2:
		
		if owner.player_index in [0, 2]:
			ui.rect_position.x = 0
			rect_position.x = 0
		else:
			ui.rect_position.x = window_width / 2
			rect_position.x = window_width / 2

		if owner.player_index in [0, 1]:
			ui.rect_position.y = 0
			rect_position.y = 0
		else:
			ui.rect_position.y = window_height / 2
			rect_position.y = window_height / 2
		
		ui.get_node('Viewport/Control').rect_size.x =  window_width / 2
		ui.get_node('Viewport/Control').rect_size.y = window_height / 2
		rect_size.x = window_width / 2
		rect_size.y = window_height / 2
		viewport.size.x = render_width / 2
		viewport.size.y = render_height / 2
		viewport.size *= render_scale

	else:
		
		if owner.player_index == 0:
			ui.rect_position.y = 0
			rect_position.y = 0
		else:
			ui.rect_position.y = window_height / 2
			rect_position.y = window_height / 2

		ui.get_node('Viewport/Control').rect_size.x = window_width
		ui.get_node('Viewport/Control').rect_size.y = window_height / 2
		rect_size.x = window_width
		rect_size.y = window_height / 2
		viewport.size.x = render_width
		viewport.size.y = render_height / 2
		viewport.size *= render_scale
	
	
#	for child in owner.get_children():
#
#		var script_name = child.get_script().get_path().get_file() if child.get_script() != null else ''
#
#		if script_name == 'Prop.Container.gd' and child.bone_name != '':
#
#			child.connect('item_added', self, '_on_item_contained')
#			child.connect('item_removed', self, '_on_item_released')
	
	
#	VisualServer.connect('viewport_pre_draw', self, '_on_pre_draw')
#	VisualServer.connect('viewport_post_draw', self, '_on_post_draw')


func _ready():
	
	_init_fp_skeleton()
	
	yield(get_tree(), 'idle_frame')
	
	_init_viewport()
	
	get_tree().root.connect('size_changed', self, '_init_viewport')
