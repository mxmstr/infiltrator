extends RayCast

var selection

signal changed_selection


func on_option_selected(interaction):
	
	selection.get_node('Behavior').start_interaction(interaction)


func _ready():
	
	selection = get_collider()


func _process(delta):
	
	#if is_colliding():
	if selection != get_collider():
		selection = get_collider()
		
		if selection != null and selection.has_node('Behavior'):
			var interactions = selection.get_node('Behavior').get_visible_interactions(self)
			emit_signal('changed_selection', interactions)
		else:
			emit_signal('changed_selection', [])
