extends Node

export(String) var stim_type


func _on_body_shape_entered(body_id, body, body_shape, area_shape):
	
	#prints(owner.name, body.name)
	
	Meta.StimulateActor(body, stim_type, owner)


func _on_body_shape_exited(body_id, body, body_shape, area_shape):
	
	pass


func _ready():
	
	owner.connect('body_shape_entered', self, '_on_body_shape_entered')
	owner.connect('body_shape_exited', self, '_on_body_shape_exited')


func _physics_process(delta):
	
	pass
#
#	if owner.get_overlapping_bodies().size():
#		print(owner.get_overlapping_bodies().size())
#
#	if owner.get_overlapping_areas().size():
#		print(owner.get_overlapping_areas().size())
	#prints(, owner.get_overlapping_bodies())
