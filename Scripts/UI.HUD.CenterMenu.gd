extends MarginContainer



func _show():
	
	visible = $MarginContainer/ListContainer._has_interactions()


func _hide():
	
	visible = false
