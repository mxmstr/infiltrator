extends Spatial

export(NodePath) var viewport

export(NodePath) var path
export(String) var bone_name

export var cam_max_x = 0.0
export var cam_max_y = PI / 2
export(Vector3) var camera_offset
export var position_offset = Vector3()
export var rotation_degrees_offset = Vector3()

var root


func _clamp_camera():
	
#	prints(cam_max_x, cam_max_y)
	$Camera.rotation.x = clamp($Camera.rotation.x, -cam_max_y, cam_max_y)
	$Camera.rotation.y = clamp($Camera.rotation.y, -cam_max_x, cam_max_x)


func _rotate_camera(delta_x, delta_y):
	
	$Camera.rotation.x += delta_x
	$Camera.rotation.y += delta_y
	
	_clamp_camera()


func _reset_camera():
	
#	print(owner.get_node('Model').get_child(0).get_path())
#	print(owner.get('CameraRig').path, path)
#	prints(path, get_node(path), bone_name)
	
	if root:
		root.queue_free()
		root = null
	
	if path and not path.is_empty():
		
		root = BoneAttachment.new()
		get_node(path).add_child(root)#.call_deferred('add_child', root)
	
		if bone_name != '':
			root.bone_name = bone_name


func _ready():
	
	_reset_camera()
	
	yield(get_tree(), 'idle_frame')
	
	$Camera.set_viewport(get_node(viewport))
	$Camera.current = true
	$Camera.translation = camera_offset


func _process(delta):

	if root:# and position_offset and rotation_degrees_offset:

		if position_offset == null or rotation_degrees_offset == null:
			return

#		root.rotation_degrees = Vector3(0, 180, 0)

		global_transform.origin = root.global_transform.origin
		translate_object_local(position_offset)

		var target_pos = global_transform.origin - root.global_transform.basis.z
		look_at(target_pos, root.global_transform.basis.y)
		rotate_x(deg2rad(rotation_degrees_offset.x))
		rotate_y(deg2rad(rotation_degrees_offset.y))
		rotate_z(deg2rad(rotation_degrees_offset.z))

		#global_transform.basis = Basis(root.global_transform.basis.get_rotation_quat())#.rotated(root.global_transform.basis.y, deg2rad(180))
#		global_transform.basis = root.global_transform.basis.rotated(root.global_transform.basis.z, deg2rad(180))


#	_clamp_camera()
