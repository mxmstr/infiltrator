extends Area


func _on_body_entered(body):
	
	ActorServer.Destroy(body)


func _ready():
	
	connect('area_entered', self, '_on_body_entered')
	connect('body_entered', self, '_on_body_entered')
