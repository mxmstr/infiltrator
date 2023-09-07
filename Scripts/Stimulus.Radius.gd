extends RayCast3D

@export var stim_type: String
@export var stim_intensity = 0.0
@export var one_shot = false
@export var continuous = false
@export var max_distance = 0.0
@export var raycast = false
@export var use_hitbox = false
@export var stim_hitbox = false
@export_multiline var required_tags

var active = true
var required_tags_dict = {}
var colliders = []
var shooter

@onready var mission = get_node_or_null('/root/Mission')
@onready var collision = get_node_or_null('../Collision')
@onready var movement = get_node_or_null('../Movement')

signal stimulate


func _ready():
	
	for tag in required_tags.split(' '):
		
		var values = Array(tag.split(':'))
		var key = values.pop_front()
		
		required_tags_dict[key] = values
	
	target_position = Vector3(0, 0, -max_distance)
	
	if owner._has_tag('Shooter'):
		shooter = owner._get_tag('Shooter')


func _validate_within_radius(actor):
	
	var within_distance = max_distance == 0 or owner.global_transform.origin.distance_to(actor.global_transform.origin) < max_distance
	
	if within_distance:
		
		if raycast:
			
			look_at(actor.global_transform.origin, Vector3(0, 1, 0))
			force_raycast_update()
			
			if not get_collider():
				return true
			
		else:
			
			return true
	
	return false


func _physics_process(delta):
	
	if not active or owner.is_queued_for_deletion() or (collision == null and collision.disabled):
		return
	
	var new_colliders = []
	var collide_actors = []
	
	for actor in mission.actors:
		
		var exceptions = owner.get_collision_exceptions() if collision else []
		
		if actor in [owner, shooter] or \
			not actor.get('tags') or \
			actor in exceptions:
			continue
		
		if not continuous and actor in colliders:
			return
		
		
		var tagged = true
		
		for item_tag in required_tags_dict.keys():
			if item_tag.length() and not actor._has_tag(item_tag):
				tagged = false
		
		if not tagged:
			continue
		
		
		if _validate_within_radius(actor):
				
				ActorServer.Stim(actor, stim_type, owner, stim_intensity)
				emit_signal('stimulate')
				
				new_colliders.append(actor)
		
		elif use_hitbox and actor.has_node('Hitboxes'):
			
			for hitbox in actor.get_node('Hitboxes').hitboxes:
				
				if _validate_within_radius(hitbox):
					
					if stim_hitbox:
						ActorServer.Stim(hitbox, stim_type, owner, stim_intensity)
					else:
						ActorServer.Stim(actor, stim_type, owner, stim_intensity)
					
					emit_signal('stimulate')
					
					new_colliders.append(actor)
					break
	
	
	colliders = new_colliders
	
	if one_shot:
		active = false
