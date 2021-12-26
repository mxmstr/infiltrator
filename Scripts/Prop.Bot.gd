extends Node

const rotate_speed = 100.0
const path_finish_range = 0.25
const melee_range = 2.0
const shoot_range = 4.0

var active = false
var target
var travelling = false
var travel_path = []

onready var map = $'/root/Mission/Static/Map'
onready var pickup_factory = $'/root/Mission/Links/PVPPickupFactory'
onready var camera = $'../CameraRig/Camera'
onready var camera_raycast = $'../CameraRaycastStim'
onready var weapon_target_lock = $'../WeaponTargetLock'
onready var behavior = $'../Behavior'
onready var movement = $'../Movement'
onready var stance = $'../Stance'
onready var stamina = $'../Stamina'
onready var perspective = $'../Perspective'
onready var right_hand = $'../RightHandContainer'


func _get_closest_pickup():
	
	if not pickup_factory.pickups.size():
		return
	
	var closest = pickup_factory.pickups[0]
	var closest_distance = owner.translation.distance_to(closest.translation)
	
	for pickup in pickup_factory.pickups.slice(1, 0):
		
		var distance = owner.translation.distance_to(pickup.translation)
		
		if distance < closest_distance:
			
			closest = pickup
			closest_distance = distance
	
	return closest


func _get_closest_enemy():
	
	var closest = weapon_target_lock.enemies[0]
	
	#if weapon_target_lock.enemies.size() > 1:
	
	var closest_distance = owner.translation.distance_to(closest.translation)
	
	for enemy in weapon_target_lock.enemies.slice(1, 0):
		
		var distance = owner.translation.distance_to(enemy.translation)
		
		if distance < closest_distance:
			
			closest = enemy
			closest_distance = distance
	
	return closest


func _start_travel():
	
	if right_hand._is_empty():
		target = _get_closest_pickup()
	else:
		target = _get_closest_enemy()
	
	if not target:
		return
	
	travelling = true
	travel_path = map.get_simple_path(owner.translation, target.translation)


func _travel():
	
	if travel_path.empty():
		
		travelling = false
	
	else:
		
		var finish_range = path_finish_range
		var distance = owner.translation.distance_to(travel_path[0])
		var local_direction = owner.transform.basis.xform_inv(owner.translation.direction_to(travel_path[0]))
		stance._set_forward_speed(local_direction.z)
		stance._set_sidestep_speed(local_direction.x)
		
		if travel_path.size() == 1:
			
			if target in weapon_target_lock.enemies:
				finish_range = shoot_range
		
		if distance < finish_range:
			travel_path.remove(0)


func _face():
	
	var closest = _get_closest_enemy()
	var enemy_shoulder_bone = closest.get_node('Hitboxes').find_node('Shoulders')
	var target_pos = enemy_shoulder_bone.transform.origin
	
	var forward = camera.global_transform.basis.z.rotated(camera.global_transform.basis.y, deg2rad(180))
	var direction_to_target = camera.global_transform.origin.direction_to(target_pos)
	var distance_to_target = camera.global_transform.origin.distance_to(target_pos)
	
	var turn_direction = forward.cross(direction_to_target).y
	var turn_speed = turn_direction * rotate_speed
	stance._set_turn_speed(turn_speed)
	
	var look_direction = direction_to_target.y - forward.y
	var look_speed = look_direction * rotate_speed
	stance._set_look_speed(look_speed)
	
	if right_hand._is_empty():
		
		if distance_to_target < melee_range:
			behavior._start_state('Punch')
		
	else:
		
		if camera_raycast.selection and \
			camera_raycast.selection._has_tag('Hitbox') and \
			camera_raycast.selection.owner in weapon_target_lock.enemies:
			behavior._start_state('UseItem')


func _process(delta):
	
	if not active:
		return
	
	if weapon_target_lock.enemies.size() == 0:
		return
	
	var dead = stamina.hp == 0
	
	if dead:
		
		if behavior.current_state == 'PostDeath':
			$'/root/Mission/Links/PVPPlayerFactory'._respawn(owner)
	
	else:
		
		if travelling:
			
			_travel()
			_face()
		
		else:
			
			_start_travel()
