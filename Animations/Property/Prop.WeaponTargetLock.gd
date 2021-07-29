extends Node

export(NodePath) var right_hand_container
export(String) var chamber_container
export(NodePath) var target


func _on_fire(container, projectile):
	
	var target_pos = (projectile.global_transform.origin - 
		projectile.global_transform.origin.direction_to(get_node(target).global_transform.origin)
	)
	
	projectile.look_at(target_pos, Vector3(0, 1, 0))


func _on_item_equipped(container, item):
	
	if item._has_tag('Firearm'):
		
		item.get_node(chamber_container).connect('item_removed', self, '_on_fire')


func _on_item_dequipped(container, item):
	
	if item._has_tag('Firearm'):
	
		item.get_node(chamber_container).disconnect('item_removed', self, '_on_fire')


func _ready():
	
	get_node(right_hand_container).connect('item_added', self, '_on_item_equipped')
	get_node(right_hand_container).connect('item_removed', self, '_on_item_dequipped')