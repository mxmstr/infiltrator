extends 'res://Scripts/AnimationTree.StateMachine.gd'

export(Inf.Priority) var priority
export(Inf.Visibility) var type
export(Inf.Blend) var blend
export var distance = 0.0
export var abilities = true
export var movement = true
export var rotation = true
export var camera_mode = 'LockYaw'


func _is_visible():
	
	return type != Inf.Visibility.INVISIBLE


func _on_state_starting(new_name):
	
	#print('Statemachine', new_name)
	
	if node_name == new_name:
		
		var playback = owner.get(parent.parameters + 'playback')
		
		if len(playback.get_travel_path()) == 0:
			
			if owner.owner.has_node('InputAbilities'):
				owner.owner.get_node('InputAbilities').active = abilities
			
			if owner.owner.has_node('InputMovement'):
				#print('Movement, ', movement)
				owner.owner.get_node('InputMovement').active = movement
			
			if owner.owner.has_node('InputRotation'):
				owner.owner.get_node('InputRotation').active = rotation
			
			if owner.owner.has_node('Perspective'):
				owner.owner.get_node('Perspective')._start_state(camera_mode)


func _ready(_owner, _parent, _parameters, _node_name):
	
	_parent.connect('state_starting', self, '_on_state_starting')
	
	._ready(_owner, _parent, _parameters, _node_name)