extends Spatial

export(NodePath) var viewport

export(NodePath) var path
export(String) var bone_name

export var camera_max_x = 0.0
export var camera_max_y = PI / 2

var root


func _clamp_camera():
	
	$Camera.rotation.x = clamp($Camera.rotation.x, -camera_max_y, camera_max_y)
	$Camera.rotation.y = clamp($Camera.rotation.y, -camera_max_x, camera_max_x)


func _rotate_camera(delta_x, delta_y):
	
	$Camera.rotation.x += delta_x
	$Camera.rotation.y += delta_y
	
	_clamp_camera()


func _ready():

	if path != null:

		root = BoneAttachment.new()
		get_node(path).call_deferred('add_child', root)
	
		if bone_name != '':
			root.bone_name = bone_name
	
	
	yield(get_tree(), 'idle_frame')
	
	$Camera.set_viewport(get_node(viewport))
	$Camera.current = true


func _process(delta):
	
	if root != null:
		
		global_transform.origin = root.global_transform.origin
		global_transform.basis = root.global_transform.basis
	
	
	_clamp_camera()
