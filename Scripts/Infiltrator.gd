extends Node

enum visibility {
	INVISIBLE,
	PHYSICAL, 
	REMOTE
}

enum blend {
	ACTION,
	MOVEMENT,
	LAYERED
}

enum RawInputType {
	ABSMOTION,
	RELMOTION,
	BUTTON,
	SCROLL,
	KEYBOARD,
	DISCONNECT,
	MAX
}

enum RawInputAxis {
	X,
	Y
}

enum RawInputScroll {
	VERTICAL,
	HORIZONTAL
}

var keycodes = []

var RawInput = {}


func _get_rawinput_status(action, mouse_device, keyboard_device):
	
	var status = 0
	
	for event in InputMap.get_action_list(action):
		
		if event is InputEventMouse:
			status = RawInput[mouse_device][RawInputType.BUTTON][event.button_mask][0]
		else:
			status = RawInput[keyboard_device][RawInputType.KEYBOARD][event.get_vkey()][0]
		
		if status == 1:
			return status
	
	return status


func _ready():
	
	var devices = Input.get_device_count()
	
	for action in InputMap.get_actions():
		for event in InputMap.get_action_list(action):
			if event is InputEventKey:
				keycodes.append(event.get_vkey())
			elif event is InputEventMouseButton:
				keycodes.append(event.button_mask)
	
	
	for device in range(devices):
		
		var typemap = []
		for type in range(len(RawInputType)):
			
			var keycodemap = {}
			for keycode in keycodes:
				keycodemap[keycode] = [0, 0, 0]
				 
			typemap.append(keycodemap)
		
		RawInput[device] = typemap


func _process(delta):
	
	for event in Input.poll_raw():
		
		if event.type in [RawInputType.BUTTON, RawInputType.KEYBOARD] \
			and not event.item in keycodes:
			return
		
		RawInput[event.device][event.type][event.item] = [event.value, event.minval, event.maxval]