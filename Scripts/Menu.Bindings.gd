extends Control

const MICE = ['P1Mouse', 'P2Mouse']
const KEYBOARDS = ['P1Keyboard', 'P2Keyboard']
const INPUT_ACTIONS = [ 'Forward', 'Backward', 'Left', 'Right', 'Jump' ]
const CONFIG_FILE = 'user://input.cfg'

var selected_device
var selected_action
var awaiting_raw_type

onready var devices_list = find_node('DevicesList')
onready var actions_list = find_node('ActionsList')
onready var hint = find_node('Hint')



func load_config():
	
	var config = ConfigFile.new()
	var err = config.load(CONFIG_FILE)
	
	if err:
		
		for action_name in INPUT_ACTIONS:
			
			var action_list = InputMap.get_action_list(action_name)
			var scancode = OS.get_scancode_string(action_list[0].scancode)
			
			config.set_value('input', action_name, scancode)
			
		config.save(CONFIG_FILE)
	
	else:
		
		for action_name in config.get_section_keys('input'):
			
			var scancode = OS.find_scancode_from_string(config.get_value('input', action_name))
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
	
	set_process_input(true)


func wait_for_rawinput(player_bind, is_keyboard=false):
	
	selected_device = player_bind
	hint.text = 'Press a key to assign a keyboard to this player.' if is_keyboard else 'Press a mouse button to assign a mouse to this player.'
	awaiting_raw_type = RawInput.Type.KEYBOARD if is_keyboard else RawInput.Type.BUTTON
	
	set_process_input(true)


func _input(event):
	
	if awaiting_raw_type == RawInput.Type.BUTTON and event is InputEventMouseButton:
		
		for device in Input.get_device_count():
			if RawInput.events[device][awaiting_raw_type][event.get_vbutton()][0] == 1:
				get_node(selected_device + '/Button')
		
		get_tree().set_input_as_handled()
		set_process_input(false)
		awaiting_raw_type = null
		
		return
	
	if awaiting_raw_type == RawInput.Type.KEYBOARD and event is InputEventKey:
		
		for device in Input.get_device_count():
			if RawInput.events[device][awaiting_raw_type][event.get_vkey()][0] == 1:
				get_node(selected_device + '/Button')
		
		get_tree().set_input_as_handled()
		set_process_input(false)
		awaiting_raw_type = null
		
		return
	
	
	if event is InputEventKey:
		
		get_tree().set_input_as_handled()
		set_process_input(false)
		
		hint.text = 'Click a key binding to reassign it, or press the Cancel action.'
		
		if not event.is_action('ui_cancel'):
			
			var scancode = OS.get_scancode_string(event.scancode)
			selected_action.get_node('Button').text = scancode
			
			for old_event in InputMap.get_action_list(selected_action.name):
				InputMap.action_erase_event(selected_action.name, old_event)
				
			InputMap.action_add_event(selected_action.name, event)
			save_to_config('Actions', selected_action.name, scancode)


func _ready():
	
	load_config()
	
	
	for mouse in MICE:
		
		var button = get_node(mouse + '/Button')
		button.connect('pressed', self, 'wait_for_rawinput', [mouse])
	
	
	for keyboard in KEYBOARDS:
		
		var button = get_node(keyboard + '/Button')
		button.connect('pressed', self, 'wait_for_rawinput', [keyboard, true])
	
	
	for action_name in INPUT_ACTIONS:
		
		var action = load('res://Scenes/UI/Menu.Bindings.Action.tscn').instance()
		action.name = action_name
		actions_list.add_child(action)
		
		var input_event = InputMap.get_action_list(action_name)[0]
		var label = action.get_node('Label')
		var button = action.get_node('Button')
		
		label.text = action_name
		button.text = OS.get_scancode_string(input_event.scancode)
		button.connect('pressed', self, 'wait_for_input', [action_name])
	
	set_process_input(false)
