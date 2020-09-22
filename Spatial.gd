extends Spatial


func _ready():
	
	add_child(load('res://Scenes/Actors/Events/Noise.tscn').instance())
	add_child(load('res://Scenes/Actors/Events/Noise.tscn').instance())