extends Camera

export(Vector3) var offset

onready var parent = $'../../../'


func _ready():
	
	pass


func _process(delta):
	
	rotation_degrees.y = parent.rotation_degrees.y + 180
	global_transform.origin = parent.global_transform.origin + offset
