extends AnimationNodeStateMachineTransition

export(float) var min_speed = 0
export(float) var max_speed = 100

var parent
var collision = null

var collisions = []


func _ready(_parent):
	
	parent = _parent
	
	parent.connect('on_physics_process', self, '_physics_process')


func _physics_process(delta):
	
	var colliders = []
	
	for collision in collisions:
		colliders.append(collision.collider)
	
	
	collision = null
	var new_collisions = []
	
	for index in range(parent.get_parent().get_slide_count()):
		
		var new_collision = parent.get_parent().get_slide_collision(index)
		#print([new_collision.collider, new_collision.travel])
		
		if not new_collision.collider in colliders \
			and new_collision.travel.length() > min_speed \
			and new_collision.travel.length() < max_speed:
			
			collision = new_collision
		
		new_collisions.append(new_collision)
	
	
	disabled = collision == null
	
	collisions = new_collisions