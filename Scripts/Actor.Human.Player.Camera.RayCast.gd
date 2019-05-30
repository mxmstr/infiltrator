extends RayCast

var selection
var last_selection

signal changed_selection


func _has_selection():
	
	return selection != null


func on_option_selected(interaction):
	
	last_selection.get_node('Behavior').start_interaction(interaction)


func _ready():
	
	selection = get_collider()


func _process(delta):
	
	#if is_colliding():
	
	if get_collider() != null:
		print(get_collider().name)
	
	if selection != get_collider():
		selection = get_collider()
		
		if selection != null and selection.has_node('Behavior'):
			var interactions = selection.get_node('Behavior')._get_visible_interactions(self)
			last_selection = selection
			emit_signal('changed_selection', interactions)
		else:
			emit_signal('changed_selection', [])
