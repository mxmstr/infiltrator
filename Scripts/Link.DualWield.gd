extends 'res://Scripts/Link.gd'

var clone
var clone_contains_link


func _on_item_removed(item):
	
	_destroy()


func _ready():
	
	clone = Meta.AddActor(to_node.system_path)
	clone_contains_link = Meta.CreateLink(from_node, clone, 'Contains', { 'container': 'LeftHandContainer' } )
	
	if not clone_contains_link:
		_destroy()
		return
	
	clone_contains_link.connect('destroyed', self, '_destroy')
	from_node.get_node('RightHandContainer').connect('item_removed', self, '_on_item_removed')
	# TODO Attempt to call function '_load_lefthand_magazine' in base 'null instance' on a null instance.
	from_node.get_node('ActionSet/ReloadAction')._load_lefthand_magazine()


func _destroy():
	
	if is_instance_valid(clone_contains_link) and not clone_contains_link.is_queued_for_deletion():
		clone_contains_link._destroy()
	
	from_node.get_node('TouchResponse')._stack_item(clone)
	
	._destroy()
