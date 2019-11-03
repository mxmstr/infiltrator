extends Node

enum Visibility {
	INVISIBLE,
	PHYSICAL, 
	REMOTE
}

enum Blend {
	ACTION,
	MOVEMENT,
	LAYERED
}

enum Priority {
	LOW,
	HIGH,
	VERY_HIGH
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

enum RawInputWheel {
	UP = 0x0A,
	DOWN = 0x0B,
	LEFT = 0x0F,
	RIGHT = 0x0E
}

enum RawInputScroll {
	VERTICAL,
	HORIZONTAL
}

var tree_count = 0
var vkeys = []
var RawInput = {}


func _make_unique(old):
	
	var dir = Directory.new()
	var new_name = old.name
	var new_filename = 'res://duplicated' + str(tree_count) + '.tscn'
	
	
	var new = load(old.filename)
	ResourceSaver.save(new_filename, new)
	
	
	new = load(new_filename).instance()
	new.name = old.name
	new.set_meta('unique', true)
	old.name += '_'

	
	old.get_parent().call_deferred('add_child_below_node', old, new)
	new.call_deferred('set_owner', old.owner)
	old.get_parent().call_deferred('remove_child', old)
	old.queue_free()
	
	
	dir.remove(new_filename)
	
	tree_count += 1


func _get_rawinput_status(action, mouse_device, keyboard_device):
	
	var status = 0
	
	for event in InputMap.get_action_list(action):
		
		var device = mouse_device if event is InputEventMouse else keyboard_device
		var type = RawInputType.BUTTON if event is InputEventMouse else RawInputType.KEYBOARD
		var item = event.get_vbutton() if event is InputEventMouse else event.get_vkey()
		
		if device == -1:
			
			for i in Input.get_device_count():
				status = RawInput[i][type][item][0]
				if status == 1:
					return status
		
		else:
			
			status = RawInput[device][type][item][0]
			if status == 1:
				return status
	
	return status


func _get_rawinput_mousemotion(device):
	
	if device == -1:
		
		var offset = Vector2()
		
		for i in Input.get_device_count():
			offset += Vector2(
				RawInput[i][RawInputType.RELMOTION][RawInputAxis.X][0],
				RawInput[i][RawInputType.RELMOTION][RawInputAxis.Y][0]
				)
		
		return offset
	
	else:
		
		return Vector2(
			RawInput[device][RawInputType.RELMOTION][RawInputAxis.X][0],
			RawInput[device][RawInputType.RELMOTION][RawInputAxis.Y][0]
			)


func _ready():
	
	var devices = Input.get_device_count()
	
	for action in InputMap.get_actions():
		for event in InputMap.get_action_list(action):
			if event is InputEventKey:
				vkeys.append(event.get_vkey())
			elif event is InputEventMouseButton:
				vkeys.append(event.get_vbutton())
	
	
	for device in range(devices):
		
		var typemap = []
		for type in range(len(RawInputType)):
			
			var keycodes
			var keycodemap = {}
			
			if type == RawInputType.RELMOTION:
				keycodes = len(RawInputAxis)
			elif type == RawInputType.SCROLL:
				keycodes = len(RawInputScroll)
			else:
				keycodes = vkeys
			
			
			for keycode in keycodes:
				keycodemap[keycode] = [0, 0, 0]
				 
			typemap.append(keycodemap)
		
		RawInput[device] = typemap


func _process(delta):
	
	for device in Input.get_device_count():
		
		RawInput[device][RawInputType.RELMOTION][RawInputAxis.X] = [0, 0, 0]
		RawInput[device][RawInputType.RELMOTION][RawInputAxis.Y] = [0, 0, 0]
	
	
	for event in Input.poll_raw():
		
		if event.type == RawInputType.SCROLL:

			var item

			if event.item == RawInputScroll.VERTICAL:
				item = RawInputWheel.UP if event.value > 0 else RawInputWheel.DOWN
			elif event.item == RawInputScroll.HORIZONTAL:
				item = RawInputWheel.RIGHT if event.value > 0 else RawInputWheel.LEFT

			event = { 'device': event.device, 'type': RawInputType.BUTTON, 'item': item, 'value': 1, 'minval': 0, 'maxval': 0 }


		if event.type in [RawInputType.BUTTON, RawInputType.KEYBOARD] \
			and not event.item in vkeys:
			return


		RawInput[event.device][event.type][event.item] = [event.value, event.minval, event.maxval]