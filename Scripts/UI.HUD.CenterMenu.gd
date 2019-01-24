extends MarginContainer



func show():
	
	visible = $MarginContainer/ListContainer.has_interactions()


func hide():
	
	visible = false
