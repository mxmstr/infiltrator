extends "res://Scripts/Input.gd"


func _on_just_activated(): 
	
	if bullet_time.active:
		bullet_time._stop()
	else:
		bullet_time._start()


func _process(delta):
	
	if not owner.is_processing_input():
		
		if bullet_time.active:
			bullet_time._stop()
