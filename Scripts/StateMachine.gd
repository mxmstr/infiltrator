extends AnimationPlayer

export(String) var start
export(String, MULTILINE) var attributes

var attributes_dict = {}
var next


func _on_animation_finished(current):
	
	if next:

		if attributes_dict.has(next):
			play(next, attributes_dict[next].blend, attributes_dict[next].speed)
		else:
			play(next)

		next = null


func _ready():
	
	attributes_dict = parse_json(attributes)
	
	connect('animation_finished', self, '_on_animation_finished')
	
	if start != '':
		_start_state(start)


func _play(_animation):
	
	if attributes_dict.has(_animation):
		
		var blend = -1.0
		var speed = 1.0
		
		if attributes_dict[_animation].has('blend'):
			blend = attributes_dict[_animation].blend
		
		if attributes_dict[_animation].has('speed'):
			blend = attributes_dict[_animation].speed
		
		play(_animation)#, blend, speed)
	
	else:
		play(_animation)


func _start_state(_name, _data={}):
	
	if attributes_dict.has(assigned_animation) and attributes_dict[assigned_animation].has('next'):
		
		next = _name
		_play(attributes_dict[assigned_animation].next)
		
		return
	
	_play(_name)
