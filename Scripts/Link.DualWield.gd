extends 'res://Scripts/Link.gd'

var clone
var clone_contains_link


func _on_item_removed(container, item):
	
	_destroy()


func _ready():
	
	clone = Meta.AddActor(to_node.system_path)
	clone_contains_link = Meta.CreateLink(from_node, clone, 'Contains', { 'container': 'LeftHandContainer' } )
	
	if not clone_contains_link:
		_destroy()
		return
	
	from_node.get_node('RightHandContainer').connect('item_removed', self, '_on_item_removed')
	from_node.get_node('ReloadAction')._load_lefthand_magazine()


func _destroy():
	
	from_node.get_node('TouchResponse')._stack_item(clone)
	
	._destroy()
