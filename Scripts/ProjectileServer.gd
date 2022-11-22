extends Node

var projectiles = []
var actors


func Create(new_actor, position=null, rotation=null, direction=null, tags={}):
	
	var projectile = Projectile.new()
	
	
	var new_transform = Transform(
		Basis(rotation if rotation else Vector3.FORWARD),
		position if position else Vector3()
		)
	
	
	var new_model
	var old_model = new_actor.get_node_or_null('Model')
	
#	if old_model:
#
#		var old_model_base = old_model.mesh.get_rid()
#
#		new_model = VisualServer.instance_create2(old_model_base, actors.get_world().scenario)
	
	
	var new_particles
	var old_particles = new_actor.get_node_or_null('Particles')

	if old_particles:

		old_particles
		var old_particles_base = old_particles.get_base()

		new_particles = VisualServer.particles_create()

		VisualServer.particles_set_amount(new_particles, old_particles.amount)
		VisualServer.particles_set_custom_aabb(new_particles, old_particles.visibility_aabb)
		VisualServer.particles_set_draw_order(new_particles, old_particles.draw_order)
		VisualServer.particles_set_draw_passes(new_particles, old_particles.draw_passes)
		VisualServer.particles_set_draw_pass_mesh(new_particles, 0, old_particles.draw_pass_1)
		#VisualServer.particles_set_emission_transform(new_particles, old_particles.emission_transform)
		VisualServer.particles_set_emitting(new_particles, true)
		VisualServer.particles_set_explosiveness_ratio(new_particles, old_particles.explosiveness)
		VisualServer.particles_set_fixed_fps(new_particles, old_particles.fixed_fps)
		VisualServer.particles_set_fractional_delta(new_particles, old_particles.fract_delta)
		VisualServer.particles_set_lifetime(new_particles, old_particles.lifetime)
		VisualServer.particles_set_one_shot(new_particles, old_particles.one_shot)
		VisualServer.particles_set_pre_process_time(new_particles, old_particles.preprocess)
		VisualServer.particles_set_process_material(new_particles, old_particles.process_material)
		VisualServer.particles_set_randomness_ratio(new_particles, old_particles.randomness)
		VisualServer.particles_set_speed_scale(new_particles, old_particles.speed_scale)
		VisualServer.particles_set_use_local_coordinates(new_particles, old_particles.local_coords)
		
		new_particles = VisualServer.instance_create2(new_particles, actors.get_world().scenario)
		
		if old_particles.one_shot:
			var time = (old_particles.lifetime * 2) / old_particles.speed_scale
			get_tree().create_timer(time).connect('timeout', self, 'Destroy', [projectile])
	
	
#	var new_collision
#	var old_collision = new_actor.get_node_or_null('Collision')
#
#	if old_collision:
#
#		var old_collision_rid = old_collision.shape.get_rid()
#		var old_collision_type = PhysicsServer.shape_get_type(old_collision_rid)
#		var old_collision_data = PhysicsServer.shape_get_data(old_collision_rid)
#
#		new_collision = PhysicsServer.shape_create(old_collision_type)
#		PhysicsServer.shape_set_data(new_collision, old_collision_data)
#
#		PhysicsServer.area_add_shape(
#			physics_shared_area.get_rid(), new_collision, new_transform
#			)
	
	
	projectile.system_path = new_actor.system_path
	projectile.transform = new_transform
	projectile.direction = Vector3(0, 0, 1)
	projectile.angular_direction = Vector2()
	projectile.speed = 0.0
	
	if new_model:
		projectile.model = new_model
	
	if new_particles:
		projectile.particles = new_particles
		projectile.particles_transform = old_particles.transform
	
#	projectile.collision_shape_rid = new_collision
	projectile.collision_exceptions = []
	projectile.tags_dict = new_actor.tags_dict
	
	if new_actor is CollisionObject:
		projectile.collision_mask = new_actor.collision_mask
	
	Meta._merge_dir(projectile.tags_dict, tags)
	
	projectiles.append(projectile)
	
	return projectile


func Destroy(projectile):
	
	projectile.valid = false
	
	if projectile.model:
		VisualServer.free_rid(projectile.model)
	
	if projectile.particles:
		VisualServer.free_rid(projectile.particles)
	
	projectiles.erase(projectile)


func SetTag(projectile, key, value):
	
	projectile.tags_dict[key] = value


func EnableCollision(projectile):
	
	var index = projectiles.find(projectile)
	
	projectile.collision_disabled = false


func DisableCollision(projectile):
	
	var index = projectiles.find(projectile)
	
	projectile.collision_disabled = true


func Stim(projectile, stim, source, intensity, position, direction):
	
	Destroy(projectile)


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


func _on_node_added(node):
	
	if not actors or not is_instance_valid(actors):
		actors = get_node_or_null('/root/Mission/Actors')


func _on_node_removed(node):
	
	if node == actors:
		
		var _projectiles = projectiles.duplicate()
		
		for i in range(0, _projectiles.size()):
			Destroy(_projectiles[i])


func _ready():
	
	get_tree().connect('node_added', self, '_on_node_added')
	get_tree().connect('node_removed', self, '_on_node_removed')


func _physics_process(delta):
	
	var _projectiles = projectiles.duplicate()
	
	for i in range(0, _projectiles.size()):
		
		var projectile = _projectiles[i]
		
		if not is_instance_valid(projectile):
			continue
		
		
		if projectile.model:
			VisualServer.instance_set_transform(projectile.model, projectile.transform)
		
		if projectile.particles:
			VisualServer.instance_set_transform(projectile.particles, projectile.transform * projectile.particles_transform)
		
		
		var angular_velocity = projectile.angular_direction * delta
		
		projectile.transform.basis = projectile.transform.basis.rotated(projectile.transform.basis.y, angular_velocity.x)
		projectile.transform.basis = projectile.transform.basis.rotated(projectile.transform.basis.x, angular_velocity.y)
		
		var offset = (
			projectile.transform.basis.xform(Vector3(0, 0, 1)) *#projectile.direction.normalized() * 
			projectile.speed * 
			delta
			)
		var new_position = projectile.transform.origin + offset
		
		
		if not projectile.collision_disabled and projectile.collision_mask:
			
			var space_state = actors.get_world().direct_space_state
			var result = space_state.intersect_ray(
				projectile.transform.origin,
				new_position,
				projectile.collision_exceptions,
				projectile.collision_mask
				)
			
			if not result.empty():
				
				ActorServer.Stim(
					result.collider, 
					'Touch',
					projectile, 
					projectile.speed,
					projectile.transform.origin,
					projectile.transform.basis.z
					)
		
		if not is_instance_valid(projectile):
			continue
		
		projectile.transform.origin = new_position