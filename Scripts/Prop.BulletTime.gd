extends Node

const max_amount = 100
const drain_rate = 20.0
const regen_rate = 2.0
const cooldown_time = 3.0

var active = false
var cooldown = false
var amount = 100.0 setget _set_amount

onready var bullet_time_server = get_node_or_null('/root/Mission/Links/BulletTimeServer')
onready var ui_audio = $'../UIAudio'

signal amount_changed


func _set_amount(new_amount):
	
	amount = clamp(new_amount, 0, max_amount)
	
	emit_signal('amount_changed', amount)


func _start():
	
	if cooldown:
		return
	
	active = true
	ui_audio._start_state('BulletTimeStart')
	bullet_time_server._start(owner)


func _stop():
	
	active = false
	ui_audio._start_state('BulletTimeEnd')
	bullet_time_server._stop(owner)


func _cooldown():
	
	cooldown = true
	
	get_tree().create_timer(cooldown_time).connect('timeout', self, 'set', ['cooldown', false])


func _ready():
	
	_set_amount(max_amount)


func _process(delta):
	
	if active:
		
		_set_amount(amount - (drain_rate * delta / Engine.time_scale))

		if amount == 0:
			_stop()
			_cooldown()
	
	elif not cooldown:
		
		_set_amount(amount + (regen_rate * delta / Engine.time_scale))
