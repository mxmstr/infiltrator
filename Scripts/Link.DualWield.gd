extends 'res://Scripts/Link.gd'

var clone
var clone_contains_link


func _ready():
	
	clone = Meta.AddActor(to_node.system_path)
	clone_contains_link = Meta.CreateLink(from_node, clone, 'Contains', { 'container': 'LeftHandContainer' } )
	
	if not clone_contains_link:
		_destroy()
		return
	
	
	


func _destroy():
	
	clone.queue_free()
	
	._destroy()
