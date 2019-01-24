extends RayCast

var selection

signal changed_selection


func _ready():
	
	selection = get_collider()


func _process(delta):
	
	#if is_colliding():
	if selection != get_collider():
		selection = get_collider()
		emit_signal('changed_selection', selection)
