extends Spatial

export var default_state = 'Default'
export(String) var bus
export var level_modifier = 0.0

var switch_mode = 'Immediate'

onready var animation_player = $AnimationPlayer
onready var audio_stream = $AudioStreamPlayer3D

signal action

var current_state = ''


func _start_state(_name, _data={}):
	
	emit_signal('action', _name, _data)


func _can_switch():
	
	return switch_mode == 'Immediate' or not animation_player.is_playing()


func _play(new_state, animation, attributes):
	
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
	
	audio_stream.bus = bus
	
	emit_signal('action', default_state, {})


func _process(delta):
	
	return
	
	audio_stream.global_transform.origin = owner.global_transform.origin
