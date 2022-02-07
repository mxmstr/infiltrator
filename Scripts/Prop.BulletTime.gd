extends Node

const max_amount = 100
const drain_rate = 20.0
const regen_rate = 5.0
const cooldown_time = 2.0

var active = false
var cooldown = false
var amount = 100.0 setget _set_amount

onready var bullet_time_server = get_node_or_null('/root/Mission/Links/BulletTimeServer')

signal amount_changed


func _set_amount(new_amount):
	
	amount = clamp(new_amount, 0, max_amount)
	
	emit_signal('amount_changed', amount)


func _start():
	
	if cooldown:
		return
	
	active = true
	bullet_time_server._start(owner)


func _stop():
	
	active = false
	bullet_time_server._stop(owner)


#func _cooldown():
#
#	cooldown = true
	


func _ready():
	
	_set_amount(max_amount)


func _process(delta):
	
	if active:
		
		_set_amount(amount - (drain_rate * delta / Engine.time_scale))
		
		if amount == 0:
			_stop()
#			_cooldown()
	
	else:
		
		_set_amount(amount + (regen_rate * delta / Engine.time_scale))
