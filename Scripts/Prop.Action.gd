extends AnimationTree

var make_unique = 0

export(NodePath) var tree_node
export var start_node = 'Start'
export var end_node = 'Start'


func _enter_tree():
	
	if tree_root.get_transition_count() == 0:
		return


#	var current_animation_player = $AnimationPlayer
#	var new_animation_player = get_node(tree_node).get_node('AnimationPlayer')
#
#	for animation_name in current_animation_player.get_animation_list():
#
#		var animation = current_animation_player.get_animation(animation_name)
#		new_animation_player.add_animation(animation_name, animation)


	var anim_names = [start_node, end_node]

	for idx in range(tree_root.get_transition_count()):

		var transition = tree_root.get_transition(idx)
		var from_name = tree_root.get_transition_from(idx)
		var to_name = tree_root.get_transition_to(idx)
		var from = tree_root.get_node(from_name)
		var to = tree_root.get_node(to_name)

		if not from_name in anim_names:

			get_node(tree_node).tree_root.add_node(from_name, from.duplicate())
			
			anim_names.append(from_name)


		if not to_name in anim_names:

			get_node(tree_node).tree_root.add_node(to_name, to.duplicate())
			
			anim_names.append(to_name)


		if from_name == tree_root.get_start_node():
			from_name = start_node
		
		if to_name == tree_root.get_end_node():
			to_name = end_node
		
		get_node(tree_node).tree_root.add_transition(from_name, to_name, transition.duplicate())