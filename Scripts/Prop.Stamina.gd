extends Node

export var hp = 100


func _damage(amount):
	
	hp -= amount
	hp = max(hp, 0)
	
	print(hp)