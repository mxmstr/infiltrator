extends Node

export var time = -1.0


func _on_timeout():
	
	owner.queue_free()


func _ready():
	
	if time != -1.0:
	
		var timer = Timer.new()
		timer.autostart = true
		timer.wait_time = time
		add_child(timer)
		
		timer.connect('timeout', self, '_on_timeout')