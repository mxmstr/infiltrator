extends RayCast

var selection
var last_selection

onready var parent = $'../../../../'

signal changed_selection


func _has_selection():
	
	return selection != null and selection.has_node('Behavior')


func _contain_selection():
	
	
	print('AAAAAAAAAAAAAAAAAAAAAAAAAAA')
	
	if _has_selection():
	
		var data = {
			'from': parent.get_path(),
			'to': selection.get_path()
			}
		
		$'/root/Game/Links'._establish_link('Contains', data)


func _ready():
	
	add_exception(parent)
	
	selection = get_collider()


func _process(delta):
	
	if selection != get_collider():
		selection = get_collider()
		emit_signal('changed_selection', selection)
