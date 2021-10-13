extends AnimationPlayer

export(String, MULTILINE) var attributes

var attributes_dict = {}
var next


func _on_animation_finished(current):
	
	if next:
		
		if attributes.has(next):
			play(next, attributes_dict[next].blend, attributes_dict[next].speed)
		else:
			play(next)
		
		next = null


func _ready():
	
	attributes_dict = parse_json(attributes)
	
	connect('animation_finished', self, '_on_animation_finished')


func _start_state(_name, _data={}):
	
	if attributes_dict.has(current_animation) and attributes_dict[current_animation].has('next'):
		
		next = _name
		
		var current = attributes_dict[current_animation]
		
		if attributes_dict.has(current):
			play(current, attributes_dict[current].blend, attributes_dict[current].speed)
		else:
			play(current)
		
		return
	
	
	if attributes_dict.has(_name):
		play(_name, attributes_dict[_name].blend, attributes_dict[_name].speed)
	else:
		play(_name)