extends Node

export(String) var bus

onready var animation_player = $AnimationPlayer
onready var audio_stream = $AudioStreamPlayer3D

signal action

var current_state = ''


func _start_state(_name, _data={}):
	
	emit_signal('action', _name, _data)


func _play(new_state, animation, attributes):
	
	current_state = new_state
	
	var level = 0
	var scale = 1.0
	var clip_start = 0
	var clip_end = 0
	
	if attributes.has('level'):
		level = attributes.level
	
	if attributes.has('speed'):
		scale = attributes.speed
	
	if attributes.has('clip_start'):
		clip_start = attributes.clip_start
	
	if attributes.has('clip_end'):
		clip_end = attributes.clip_end
	
	
	audio_stream.unit_db = level
	animation_player.stop()
	animation_player.play(animation, -1, scale)


func _ready():
	
	audio_stream.bus = bus


func _process(delta):

	audio_stream.global_transform.origin = owner.global_transform.origin
