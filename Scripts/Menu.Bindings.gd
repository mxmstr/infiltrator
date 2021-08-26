extends Control

const MICE = ['p1_mouse', 'p2_mouse']
const KEYBOARDS = ['p1_keyboard', 'p2_keyboard']
const INPUT_ACTIONS = [ 'Forward', 'Backward', 'Left', 'Right', 'Jump' ]
const CONFIG_FILE = 'user://input.cfg'

var selected_device
var selected_action
var awaiting_raw_type

onready var devices_list = find_node('DevicesList')
onready var actions_list = find_node('ActionsList')
onready var hint = find_node('Hint')

signal disable_buttons


func load_config():
	
	var config = ConfigFile.new()
	var err = config.load(CONFIG_FILE)
	
	if err:
		
		for mouse in MICE:
			
			config.set_value('Devices', mouse, -1)
		
		for keyboard in KEYBOARDS:
			
			config.set_value('Devices', keyboard, -1)
		
		for action_name in INPUT_ACTIONS:
			
			var action_list = InputMap.get_action_list(action_name)
			var scancode = OS.get_scancode_string(action_list[0].scancode)
			
			config.set_value('Actions', action_name, scancode)
			
		config.save(CONFIG_FILE)
	
	else:
		
		for device in config.get_section_keys('Devices'):
			
			Meta.set(device, config.get_value('Devices', device))
		
		for action_name in config.get_section_keys('Actions'):
			
			var scancode = OS.find_scancode_from_string(config.get_value('Actions', action_name))
			var event = InputEventKey.new()
			event.scancode = scancode
			
			for old_event in InputMap.get_action_list(action_name):
				if old_event is InputEventKey:
					InputMap.action_erase_event(action_name, old_event)
			
			InputMap.action_add_event(action_name, event)


func save_to_config(section, key, value):
	
	var config = ConfigFile.new()
	var err = config.load(CONFIG_FILE)
	
	if err:
		print('Error code when loading config file: ', err)
	else:
		config.set_value(section, key, value)
		config.save(CONFIG_FILE)


func wait_for_input(action_bind):
	
	selected_action = actions_list.get_node(action_bind)
	hint.text = 'Press a key to assign to the "' + selected_action.name + '" action.'
	
	emit_signal('disable_buttons', true)
	
	set_process_input(true)


func wait_for_rawinput(player_bind, is_keyboard=false):
	
	selected_device = player_bind
	awaiting_raw_type = RawInput.Type.KEYBOARD if is_keyboard else RawInput.Type.BUTTON
	hint.text = 'Press a key to assign a keyboard to this player.' if is_keyboard else 'Press a mouse button to assign a mouse to this player.'
	
	RawInput.connect('device_activated', self, '_on_rawinput_device_activated')
	
	emit_signal('disable_buttons', true)


func quit_wait_for_input():
	
	hint.text = ''
	awaiting_raw_type = null
	
	RawInput.disconnect('device_activated', self, '_on_rawinput_device_activated')
	
	emit_signal('disable_buttons', false)
	
	get_tree().set_input_as_handled()
	set_process_input(false)


func _on_rawinput_device_activated(device_id, type):
	
	#print([device_id, type])
	
	if type != awaiting_raw_type:
		return
	
	devices_list.get_node(selected_device + '/Button').text = str(device_id)
	Meta.set(selected_device, device_id)
	
	save_to_config('Devices', selected_device, device_id)
	
	quit_wait_for_input()


func _input(event):
	
	if awaiting_raw_type == null:
		
		if event is InputEventKey:
		
			if not event.is_action('ui_cancel'):
				
				var scancode = OS.get_scancode_string(event.scancode)
				selected_action.get_node('Button').text = scancode
				
				for old_event in InputMap.get_action_list(selected_action.name):
					InputMap.action_erase_event(selected_action.name, old_event)
					
				InputMap.action_add_event(selected_action.name, event)
				save_to_config('Actions', selected_action.name, scancode)
			
			quit_wait_for_input()


func _ready():
	
	load_config()
	
	
	for mouse in MICE:
		
		var button = devices_list.get_node(mouse + '/Button')
		button.text = str(Meta.get(mouse))
		button.connect('pressed', self, 'wait_for_rawinput', [mouse])
		connect('disable_buttons', button, 'set_disabled')
	
	
	for keyboard in KEYBOARDS:
		
		var button = devices_list.get_node(keyboard + '/Button')
		button.text = str(Meta.get(keyboard))
		button.connect('pressed', self, 'wait_for_rawinput', [keyboard, true])
		connect('disable_buttons', button, 'set_disabled')
	
	
	for action_name in INPUT_ACTIONS:
		
		var input_event = InputMap.get_action_list(action_name)[0]
		
		if input_event is InputEventKey:
		
			var action = load('res://Scenes/UI/Menu.Inputs.Action.tscn').instance()
			action.name = action_name
			actions_list.add_child(action)
			
			var label = action.get_node('Label')
			var button = action.get_node('Button')
			
			label.text = action_name
			button.text = OS.get_scancode_string(input_event.scancode)
			button.connect('pressed', self, 'wait_for_input', [action_name])
			connect('disable_buttons', button, 'set_disabled')
	
	
	set_process_input(false)
