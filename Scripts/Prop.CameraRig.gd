extends Spatial

export(NodePath) var viewport

export(NodePath) var path
export(String) var bone_name

var root


func _ready():

	root = BoneAttachment.new()
	get_node(path).call_deferred('add_child', root)

	if bone_name != '':
		root.bone_name = bone_name
	
	
	yield(get_tree(), 'idle_frame')
	
	$Camera.set_viewport(get_node(viewport))
	$Camera.current = true


func _process(delta):

	global_transform.origin = root.global_transform.origin
	global_transform.basis = root.global_transform.basis