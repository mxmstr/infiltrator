extends 'res://Scripts/Prop.Movement.gd'


func _teleport(new_position=null, new_rotation=null):
	
	if new_position != null:
		owner.global_transform.origin = new_position
	
	if new_rotation != null:
		owner.rotation = new_rotation


#func _physics_process(delta):
#
#	velocity.y += delta * gravity
#owner.set_velocity(direction * speed)
#owner.set_up_direction(Vector3(0, 1, 0))
#owner.move_and_slide()
#	velocity = owner.velocity
