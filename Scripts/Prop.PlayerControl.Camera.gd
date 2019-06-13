extends Camera

export(Vector3) var offset

onready var parent = $'../../../'


func _ready():
	
	pass


func _process(delta):
	
	rotation.y = parent.rotation.y
	global_transform.origin = parent.global_transform.origin + offset
