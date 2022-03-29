extends Area


func _on_body_entered(body):
	
	Meta.DestroyActor(body)


func _ready():
	
	connect('area_entered', self, '_on_body_entered')
	connect('body_entered', self, '_on_body_entered')
