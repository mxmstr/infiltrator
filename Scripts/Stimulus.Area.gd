extends Area

export(String) var stim_type

var collision_disabled = false

onready var collision = get_node_or_null('../Collision')
onready var movement = get_node_or_null('../Movement')

signal stimulate


func _on_body_entered(body):
	
	if not collision or collision.disabled:
		return

	if body in movement.collision_exceptions:
		return

	ActorServer.Stim(body, stim_type, owner)
	emit_signal('stimulate')


func _on_body_exited(body):

	pass


func _ready():

	connect('body_entered', self, '_on_body_entered')
	connect('body_exited', self, '_on_body_exited')


func _physics_process(delta):
	
	if collision and collision.disabled:
		collision_disabled = true
	
	elif collision_disabled and collision and not collision.disabled:
		
		for body in get_overlapping_bodies():
			_on_body_entered(body)
		
		collision_disabled = false
	
