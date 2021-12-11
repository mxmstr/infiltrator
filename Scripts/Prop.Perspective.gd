extends ViewportContainer

export var mouse_device = -1
export var keyboard_device = -1
export var gamepad_device = -1
export var fp_offset = Vector3(0, 0, 0)
export(String) var fp_root_bone
export(String) var fp_shoulder_bone
export(Array, String) var fp_hidden_bones

var viewmodel_offset = 5
var worldmodel_offset = 15

var rig_translated = false
var rig_rotated = false
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
	
	
	var viewmodel = preload('res://Scenes/Components/Properties/ViewModel.property.tscn').instance()
	viewmodel.name = 'ActorViewModel'
	viewmodel.model = $'../Model'
	viewmodel.hidden_bones = fp_hidden_bones
	viewmodel.follow_camera_bone_id = shoulders_id
	viewmodel.follow_camera_offset = fp_offset
	
	owner.add_child(viewmodel)
	viewmodel.owner = owner


func _init_viewport():
	
#	$Container/Viewport.world = get_tree().root.world
#	$Container/Viewport.size = get_tree().root.size
	
	
	for child in owner.get_children():

		var script_name = child.get_script().get_path().get_file() if child.get_script() != null else ''

		if script_name == 'Prop.Container.gd' and child.bone_name != '':

			child.connect('item_added', self, '_on_item_contained')
			child.connect('item_removed', self, '_on_item_released')
	
	
#	VisualServer.connect('viewport_pre_draw', self, '_on_pre_draw')
#	VisualServer.connect('viewport_post_draw', self, '_on_post_draw')


func _ready():
	
	yield(get_tree(), 'idle_frame')
	
	_init_fp_skeleton()
	#_init_viewport()
