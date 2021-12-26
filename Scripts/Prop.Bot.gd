extends Node

var active = false
var target
var travelling = false
var travel_path = []

onready var map = $'/root/Mission/Static/Map'
onready var pickup_factory = $'/root/Mission/Links/PVPPickupFactory'
onready var camera_raycast = $'../CameraRaycastStim'
onready var weapon_target_lock = $'../WeaponTargetLock'
onready var movement = $'../Movement'
onready var stance = $'../Stance'


func _start_travel():
	
	if weapon_target_lock.enemies.size():
		
		target = weapon_target_lock.enemies[0]
		
		if weapon_target_lock.enemies.size() > 1:
			
			var closest_distance = owner.translation.distance_to(target.translation)
			
			for enemy in weapon_target_lock.enemies.slice(1):
				
				var distance = owner.translation.distance_to(enemy.translation)
				
				if distance < closest_distance:
					
					target = enemy
					closest_distance = distance
		
		travelling = true
		travel_path = map.get_simple_path(owner.translation, target.translation)


func _travel():
	
	if travel_path.empty():
		
		travelling = false
	
	else:
		
		var distance = owner.translation.distance_to(travel_path[0])
		var local_direction = owner.transform.basis.xform_inv(owner.translation.direction_to(travel_path[0]))
		stance._set_forward_speed(local_direction.z)
		stance._set_sidestep_speed(local_direction.x)
		
		var forward = owner.transform.basis.z
		var direction_to_target = owner.translation.direction_to(target.translation)
		var turn_direction = forward.cross(direction_to_target).y
		var turn_speed = turn_direction * Meta.rotate_sensitivity
		stance._set_turn_speed(turn_speed)
		
		if distance < 0.25:
			travel_path.remove(0)


func _process(delta):
	
	if not active:
		return
	
	if travelling:
		
		_travel()
	
	else:
		
		_start_travel()
