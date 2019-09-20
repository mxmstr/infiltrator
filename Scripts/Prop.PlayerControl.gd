extends ViewportContainer

export var mouse_device = -1
export var keyboard_device = -1

var player_index = 0


func _ready():
	
	var camera = $Viewport/Camera
	var mesh = $'../Model'.get_child(0).get_child(0)
	
	
	camera.set_cull_mask_bit(15, true)
	mesh.set_layer_mask_bit(15, false)
	
	
	camera.set_cull_mask_bit(15 + player_index, false)
	mesh.set_layer_mask_bit(0, false)
	mesh.set_layer_mask_bit(15 + player_index, true)