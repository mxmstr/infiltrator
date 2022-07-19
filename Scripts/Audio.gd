extends Spatial

export var default_state = 'Default'
export(String) var bus
export var level_modifier = 0.0
export var time_scaled = true

var switch_mode = 'Immediate'

onready var animation_player = $AnimationPlayer
onready var audio_stream = $AudioStreamPlayer3D
onready var bullet_time_server = $'/root/Mission/Links/BulletTimeServer'

signal action

var current_state = ''


func _on_bullet_time_started():
	
	if time_scaled:
		audio_stream.pitch_scale = Engine.time_scale


func _on_bullet_time_ended():
	
	audio_stream.pitch_scale = 1.0


func _start_state(_name, _data={}):
	
	emit_signal('action', _name, _data)


func _can_switch():
	
	return switch_mode == 'Immediate' or not animation_player.is_playing()


func _add_animation(animation_name, animation_res):
	
	animation_player.add_animation(animation_name, animation_res)


func _play(new_state, animation, attributes, _data):
	
	if not _can_switch():
		return
	
	current_state = new_state
	
	var level = 0
	var scale = 1.0
	var clip_start = 0
	var clip_end = 0
	switch_mode = 'Immediate'
	
	if attributes.has('level'):
		level = attributes.level
	
	if attributes.has('speed'):
		scale = attributes.speed
	
	if attributes.has('clip_start'):
		clip_start = attributes.clip_start
	
	if attributes.has('clip_end'):
		clip_end = attributes.clip_end
	
	if attributes.has('switch_mode'):
		switch_mode = attributes.switch_mode
	
	audio_stream.unit_db = level + level_modifier
	animation_player.stop()
	animation_player.play(animation, -1, scale)


func _ready():
	
	bullet_time_server.connect('started', self, '_on_bullet_time_started')
	bullet_time_server.connect('ended', self, '_on_bullet_time_ended')
	
	audio_stream.bus = bus
	audio_stream.pitch_scale = Engine.time_scale
	
	yield(get_tree(), 'idle_frame')
	
	call_deferred('emit_signal', 'action', default_state, {})
