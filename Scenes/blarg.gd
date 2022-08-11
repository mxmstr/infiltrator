extends Spatial

var particles


func _ready():
	
	particles = Meta.preloader.get_resource('res://Scenes/Actors/Items/Bullet2.tscn').instance().get_node('Particles').duplicate()


func _process(delta):
	
	particles.global_transform.origin = global_transform.origin
