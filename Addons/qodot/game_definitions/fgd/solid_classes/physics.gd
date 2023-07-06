class_name PhysicsEntity
extends RigidBody3D
@tool

@export var properties: Dictionary : set = set_properties

func set_properties(new_properties : Dictionary) -> void:
	if(properties != new_properties):
		properties = new_properties
		update_properties()

func update_properties():
	if 'velocity' in properties:
		linear_velocity = properties['velocity']

	if 'mass' in properties:
		mass = properties.mass


func use():
	bounce()

func bounce():
	linear_velocity.y = 10
