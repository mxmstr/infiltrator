extends AnimationTree


func _ready():
	
	var skeleton = $'../../Model'.get_children()[0].duplicate()
	
	for child in skeleton.get_children():
		child.queue_free()
	
	$AnimationPlayer.add_child(skeleton)
	$AnimationPlayer.root_node = NodePath(skeleton.name)
	
	anim_player = NodePath('AnimationPlayer')
	active = true