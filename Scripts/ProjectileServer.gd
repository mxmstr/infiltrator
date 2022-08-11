extends Node

var projectiles = []
var actors
var physics_shared_area

#func _create_collision(new_actor):
#
#	PhysicsServer.area


func Create(new_actor, position=null, rotation=null, direction=null, tags={}):
	
	var new_transform = Transform(
		Basis(rotation if rotation else Vector3.FORWARD),
		position if position else Vector3()
		)
	
	var new_collision
	var old_collision = new_actor.get_node_or_null('Collision')
	
	if old_collision:
		
		new_collision = old_collision.shape.get_rid()
		
		PhysicsServer.area_add_shape(
			physics_shared_area.get_rid(), new_collision, new_transform
			)
	
	var projectile = Projectile.new()
	projectile.system_path = new_actor.system_path
	projectile.transform = new_transform
	projectile.direction = Vector3(0, 0, 1)
	projectile.angular_direction = Vector2()
	projectile.speed = 0.0
	projectile.collision_shape = new_collision
	projectile.collision_exceptions = []
	projectile.tags_dict = new_actor.tags_dict
	
	Meta._merge_dir(projectile.tags_dict, tags)
	
	projectiles.append(projectile)
	
	return projectile


func Destroy(projectile):
	
	PhysicsServer.free_rid(projectile.collision_shape)
	projectiles.erase(projectile)


func SetTag(projectile, key, value):
	
	projectile.tags_dict[key] = value


func EnableCollision(projectile):
	
	var index = projectiles.find(projectile)
	
	PhysicsServer.area_set_shape_disabled(physics_shared_area.get_rid(), index, false)


func DisableCollision(projectile):
	
	var index = projectiles.find(projectile)
	
	PhysicsServer.area_set_shape_disabled(physics_shared_area.get_rid(), index, true)


func SetDirection(projectile, new_direction):
	
	projectile.direction = new_direction


func SetDirectionLocal(projectile, new_direction):
	
	projectile.direction = projectile.transform.basis.xform(new_direction)


func SetSpeed(projectile, new_speed):
	
	projectile.speed = new_speed


func SetAngularDirection(projectile, new_direction):
	
	projectile.angular_direction = new_direction


func AddCollisionException(projectile, other):
	
	projectile.collision_exceptions.append(other)


func RemoveCollisionException(projectile, other):
	
	projectile.collision_exceptions.remove(other)


func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	
	#var shape = PhysicsServer.area_get_shape(physics_shared_area.get_rid(), local_shape_index)
	var projectile = projectiles[local_shape_index]
	
	if body in projectile.collision_exceptions:
		return
	
	ActorServer.Stim(
		body, 
		'Touch',
		projectile, 
		projectile.speed,
		projectile.transform.origin,
		projectile.transform.basis.z
		)


func _on_node_added(node):
	
	if not actors:
		actors = get_node_or_null('/root/Mission/Actors')
	
	if not physics_shared_area:
		
		physics_shared_area = get_node_or_null('/root/Mission/PhysicsSharedArea')
		
		if physics_shared_area:
			physics_shared_area.connect('body_shape_entered', self, '_on_body_shape_entered')


func _ready():
	
	get_tree().connect('node_added', self, '_on_node_added')


func _physics_process(delta):
	
	var bullets_queued_for_destruction = []
	
	for i in range(0, projectiles.size()):
		
		var projectile = projectiles[i]
		var offset = (
			projectile.direction.normalized() * 
			projectile.speed * 
			delta
			)
		
		projectile.transform.origin += offset
		
		var index = projectiles.find(projectile)
		
		PhysicsServer.area_set_shape_transform(
			physics_shared_area.get_rid(), 
			index, 
			projectile.transform
		)
