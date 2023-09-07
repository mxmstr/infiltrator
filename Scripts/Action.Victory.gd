extends "res://Scripts/AnimationLoader.gd"

@export var state: String

var new_state = ''


func _ready():
	
	await super()
	
	tree_node.connect('action_started',Callable(self,'_on_action'))


func _on_action(_state, data): 
	
	new_state = _state
	
	if new_state == state:
		
		tree_node.current_state = state
		tree_node.priority = 2
		tree_node.endless = true
		tree_node.camera_mode._start_state('Default')
		tree_node.hud_mode._start_state('Victory')
