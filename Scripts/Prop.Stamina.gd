extends Node

export var hp = 100 setget _set_hp

signal damaged
signal just_died


func _set_hp(new_hp):
	
	hp = new_hp
	emit_signal('damaged', hp)


func _damage(amount):
	
	var current = hp
	
	hp -= amount
	hp = max(hp, 0)
	
	emit_signal('damaged', hp)
	
	if current > 0 and hp == 0:
		emit_signal('just_died')
