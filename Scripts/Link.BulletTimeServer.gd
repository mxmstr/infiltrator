extends 'res://Scripts/Link.gd'

const time_scale = 0.25

var users = []


func _exit_tree():
	
	Engine.time_scale = 1.0


func _start(user):
	
	if not user in users:
		users.append(user)
	
	Engine.time_scale = time_scale


func _stop(user):
	
	users.erase(user)
	
	if users.empty():
		Engine.time_scale = 1.0
