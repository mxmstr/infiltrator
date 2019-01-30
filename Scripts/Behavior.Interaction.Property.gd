tool
extends HBoxContainer


func update_value(parent, prop):
	
	$Property.text = str(prop)
	$Value.text = str(parent.get(prop))


func _ready():
	
	pass


