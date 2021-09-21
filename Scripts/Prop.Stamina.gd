extends Node

export var hp = 100

signal just_died


func _damage(amount):
	
	var current = hp
	
	hp -= amount
	hp = max(hp, 0)
	
	if current > 0 and hp == 0:
		emit_signal('just_died')