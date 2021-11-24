extends RayCast

export(NodePath) var right_hand_container
export(String) var chamber_container

var model
var camera
var camera_raycast
var camera_raycast_target
var perspective

var enemies = []
var visible_enemies = []
var targeted_enemy
var targeted_enemy_bone
var shoulder_bone
var auto_aim = false

onready var stamina = get_node_or_null('../Stamina')


func _on_fire(container, projectile):
	
#	var target_pos = (projectile.global_transform.origin - 
#		projectile.global_transform.origin.direction_to(camera_raycast_target.global_transform.origin)
#	)
	#var target_pos = projectile.global_transform.origin.direction_to(camera_raycast_target.global_transform.origin)
	
	projectile.look_at(camera_raycast_target.global_transform.origin, Vector3.UP)


func _on_camera_entered(_camera, actor):
	
	if _camera == camera and actor.get_node('Stamina').hp > 0:
		
		visible_enemies.append(actor)
		
		_select_target()


func _on_camera_exited(_camera, actor):
	
	if _camera == camera:
		
		visible_enemies.erase(actor)
		
		_select_target()


func _on_item_equipped(container, item):
	
	if item._has_tag('Firearm'):
		
		item.get_node(chamber_container).connect('item_removed', self, '_on_fire')


func _on_item_dequipped(container, item):
	
	if item._has_tag('Firearm'):
		
		item.get_node(chamber_container).disconnect('item_removed', self, '_on_fire')


func _select_target():
	
	if not visible_enemies.size():
		
		targeted_enemy = null
		return
	
	
	var closest_enemy
	var closest_distance
	
	for enemy in visible_enemies:
		
		var height = enemy.get_node('Collision').shape.extents.y
		var screen_pos = camera.unproject_position(enemy.translation + Vector3(0, height / 2, 0))
		var distance = screen_pos.distance_to(Vector2(perspective.rect_size.x / 2, perspective.rect_size.y / 2))
		
		if not closest_distance or distance < closest_distance:
			
			closest_distance = distance
			closest_enemy = enemy
	
	targeted_enemy = closest_enemy
	targeted_enemy_bone = targeted_enemy.get_node('Hitboxes').find_node('Shoulders')
	shoulder_bone = owner.get_node('Hitboxes').find_node('Shoulders')


func _ready():
	
	model = get_node_or_null('../Model')
	camera = get_node_or_null('../CameraRig/Camera')
	camera_raycast = get_node_or_null('../CameraRaycastStim')
	camera_raycast_target = get_node_or_null('../CameraRaycastStim/Target')
	perspective = get_node_or_null('../Perspective')
	
	get_node(right_hand_container).connect('item_added', self, '_on_item_equipped')
	get_node(right_hand_container).connect('item_removed', self, '_on_item_dequipped')
	
	yield(get_tree(), 'idle_frame')
	
	if auto_aim:
		
		for actor in $'/root/Mission/Actors'.get_children():
			
			if actor != owner and actor.get('tags') and actor._has_tag('Team'):
				
				var their_team = int(actor._get_tag('Team'))
				var my_team = int(owner._get_tag('Team'))
				
				if their_team == Meta.Team.None or their_team != my_team:
					
					enemies.append(actor)
					actor.get_node('VisibilityNotifier').connect('camera_entered', self, '_on_camera_entered', [actor])
					actor.get_node('VisibilityNotifier').connect('camera_exited', self, '_on_camera_exited', [actor])


func _process(delta):
	
	var dead = stamina.hp == 0
	
	if not dead and auto_aim and targeted_enemy:
		
		var target_dead = targeted_enemy.get_node('Stamina').hp == 0
		
		if not is_instance_valid(targeted_enemy) or target_dead:
			targeted_enemy = null
			targeted_enemy_bone = null
			return
		
		if camera_raycast.get_collider() and camera_raycast.get_collider().owner in enemies:
			
			camera_raycast.move_target = true
		
		else:
			
			var target_pos = targeted_enemy_bone.global_transform.origin
			
			global_transform.origin = shoulder_bone.global_transform.origin
			
			var space_state = get_world().direct_space_state
			var result = space_state.intersect_ray(
				shoulder_bone.global_transform.origin, target_pos, [owner], collision_mask
				)
			
			if result:
				camera_raycast.move_target = true
				model.rotation = Vector3(0, 0, 0)
				return
			
			camera_raycast.move_target = false
			camera_raycast_target.global_transform.origin = target_pos
			
			var target_pos_horizontal = Vector3(target_pos.x, model.global_transform.origin.y, target_pos.z)
			model.look_at(target_pos_horizontal, Vector3.UP)
			model.rotate_y(deg2rad(180))
			
	else:
		
		camera_raycast.move_target = true
		model.rotation = Vector3(0, 0, 0)