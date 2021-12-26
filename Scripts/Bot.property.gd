extends Node

var active = false
var travelling = false
var travel_path = []

onready var map = $'/root/Mission/Static/Map'
onready var weapon_target_lock = $'../WeaponTargetLock'
onready var movement = $'../Movement'
onready var stance = $'../Stance'


func _start_travel():
	
	if weapon_target_lock.enemies.size():
		
		var closest_enemy = weapon_target_lock.enemies[0]
		
		if weapon_target_lock.enemies.size() > 1:
			
			var closest_distance = owner.translation.distance_to(closest_enemy.translation)
			
			for enemy in weapon_target_lock.enemies.slice(1):
				
				var distance = owner.translation.distance_to(enemy.translation)
				
				if distance < closest_distance:
					
					closest_enemy = enemy
					closest_distance = distance
		
		travelling = true
		travel_path = map.get_simple_path(owner.translation, closest_enemy.translation)


func _travel():
	
	if travel_path.empty():
		travelling = false
	
	else:
		
		var distance = owner.translation.distance_to(travel_path[0])
		var local_direction = owner.transform.basis.xform_inv(owner.translation.direction_to(travel_path[0]))
		stance._set_forward_speed(local_direction.z)
		stance._set_sidestep_speed(local_direction.x)
		stance
		
		if distance < 0.25:
			travel_path.remove(0)


func _process(delta):
	
	if not active:
		return
	
	if travelling:
		
		_travel()
		
	else:
		
		_start_travel()
