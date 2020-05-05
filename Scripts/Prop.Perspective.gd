#tool
extends 'res://Scripts/AnimationTree.gd'

export var mouse_device = -1
export var keyboard_device = -1
export var fp_offset = Vector3(0, 0, 0.1)
export(String) var fp_root_bone
export(String) var fp_shoulder_bone
export(Array, String) var fp_hidden_bones

var viewmodel_offset = 5
var worldmodel_offset = 15

var rig_translated = false
var rig_rotated = false

var viewmodels = []

onready var rig = $'../CameraRig'
onready var camera = rig.get_node('Camera')


func _on_pre_draw(viewport):
	
	pass
#	if viewport == $Container/Viewport.get_viewport_rid():
#
#		for child in owner.get_children():
#
#			var script_name = child.get_script().get_path().get_file() if child.get_script() != null else ''
#
#			if script_name == 'Prop.Container.gd' and child.bone_name != '':
#
#				var last = child.root.transform.origin
#
#				child.root.global_transform.origin = Vector3(-0.04, 1.23, 0.74)
#				#child.root.bone_name = child.bone_name
#				#child.root.force_update_transform()
#
#				child._move_items()
#
#				#child.root.transform.origin = last
#
##				var root = child.root
##				var fp_root = BoneAttachment.new()
##				fp_root.bone_name = root.bone_name
##				$'../ViewModel'.get_child(0).add_child(fp_root)
##				fp_root.force_update_transform()
##
##				child.root = fp_root
##				child._move_items()
##
##				child.root = root
##				fp_root.free()


func _on_post_draw(viewport):
	
	pass
#	if viewport == $Container/Viewport.get_viewport_rid():
#
#		for child in owner.get_children():
#
#			var script_name = child.get_script().get_path().get_file() if child.get_script() != null else ''
#
#			if script_name == 'Prop.Container.gd' and child.bone_name != '':
#
##				child.root.translation = Vector3(0, 0, 0)
##				child.root.bone_name = child.bone_name
#				#child.root.global_transform.origin = Vector3(0, 0, 0)
#				#child.root.force_update_transform()
#				pass
#				#child._move_items()


func _on_item_contained(container, item):
	
	var viewmodel = load('res://Scenes/Components/Properties/P.ViewModel.tscn').instance()
	viewmodel.name = item.name + 'ViewModel'
	viewmodel.model = item.get_node('Model')
	viewmodel.bone_name = container.bone_name if container.bone_name != '' else null
	
	owner.add_child(viewmodel)
	viewmodel.owner = owner
	
	#viewmodels.append(viewmodel)


func _on_item_released(container, item):
	
	owner.remove_child(owner.get_node(item.name + 'ViewModel'))
	
	#viewmodels.remove(viewmodel)


func _init_fp_skeleton():
	
	var root_id
	var shoulders_id
	
	for idx in range($'../Model'.get_child(0).get_bone_count()):
		
		var bone_name = $'../Model'.get_child(0).get_bone_name(idx)
		
		if bone_name == fp_root_bone:
			root_id = idx
		
		if bone_name == fp_shoulder_bone:
			shoulders_id = idx
	
	
	var viewmodel = load('res://Scenes/Components/Properties/P.ViewModel.tscn').instance()
	viewmodel.name = 'ActorViewModel'
	viewmodel.model = $'../Model'
	viewmodel.hidden_bones = fp_hidden_bones
	viewmodel.follow_camera_bone_id = shoulders_id
	viewmodel.follow_camera_offset = fp_offset
	
	owner.add_child(viewmodel)
	viewmodel.owner = owner


func _init_viewport():
	
	$Container/Viewport.world = get_tree().root.world
	$Container/Viewport.size = get_tree().root.size
	
	
	for child in owner.get_children():

		var script_name = child.get_script().get_path().get_file() if child.get_script() != null else ''

		if script_name == 'Prop.Container.gd' and child.bone_name != '':
			
			child.connect('item_added', self, '_on_item_contained')
			child.connect('item_removed', self, '_on_item_released')
	
	
	VisualServer.connect('viewport_pre_draw', self, '_on_pre_draw')
	VisualServer.connect('viewport_post_draw', self, '_on_post_draw')


func _ready():
	
	if Engine.editor_hint: return
	
	if not has_meta('unique'):
		return
	
	yield(get_tree(), 'idle_frame')
	
	_init_fp_skeleton()
	_init_viewport()
