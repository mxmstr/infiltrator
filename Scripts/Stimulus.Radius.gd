extends RayCast

export(String) var stim_type
export var continuous = false
export var max_distance = 0.0
export var raycast = false
export var use_hitbox = false
export(String, MULTILINE) var required_tags

var required_tags_dict = {}
var colliders = []
var shooter

onready var actors = get_node_or_null('/root/Mission/Actors')
onready var collision = get_node_or_null('../Collision')
onready var movement = get_node_or_null('../Movement')


func _ready():
	
	for tag in required_tags.split(' '):
		
		var values = Array(tag.split(':'))
		var key = values.pop_front()
		
		required_tags_dict[key] = values
	
	cast_to = Vector3(0, 0, -max_distance)
	
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
	
	if owner.is_queued_for_deletion() or (collision and collision.disabled):
		return
	
	var new_colliders = []
	var collide_actors = []
	
	for actor in actors.get_children() if actors else []:
		
		if not actor.get('tags') or \
			(use_hitbox and not actor.has_node('Hitboxes')) or \
			actor in owner.get_collision_exceptions():
			continue
		
		var tagged = true
		
		for item_tag in required_tags_dict.keys():
			if item_tag.length() and not actor._has_tag(item_tag):
				tagged = false
		
		if not tagged:
			continue
		
		if use_hitbox:
			
			for hitbox in actor.get_node('Hitboxes').get_children():
				
				if _validate_within_radius(hitbox):
					collide_actors.append(actor)
					break
		
		else:
			
			if _validate_within_radius(actor):
				collide_actors.append(actor)
	
	
	for actor in collide_actors:
		
		if actor in [owner, shooter]:
			continue
		
		if not continuous and actor in colliders:
			return
		
		Meta.StimulateActor(actor, stim_type, owner)
		new_colliders.append(actor)
	
	
	colliders = new_colliders
