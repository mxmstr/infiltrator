extends 'res://Scripts/AnimationTree.Node.gd'

const schemas_dir = 'res://Scenes/Components/Schemas/'

export(String) var schema_name

var animation_list = []


func _on_state_starting(new_name):
	
	._on_state_starting(new_name)
	
	animation_list.shuffle()
	animation = animation_list[0]


func _ready(_owner, _parent, _parameters, _name):
	
	._ready(_owner, _parent, _parameters, _name)
	
	var animation_player = owner.get_node('AnimationPlayer')
	var tags = []
	
	if owner.owner._has_tag(owner.schema_type):
		tags = owner.owner._get_tag(owner.schema_type)
	
	
	var selected_schema
	var selected_schema_tag_count = 0
	var files = []
	var dir = Directory.new()
	dir.open(schemas_dir)
	dir.list_dir_begin()
	
	while true:
		
		var file = dir.get_next()
		
		if file == '':
			break
		
		if not file.begins_with(schema_name) or not file.ends_with('.tscn'):
			continue
		
		if selected_schema == null:
			selected_schema = file
			continue
		
		var tag_count = 0
		
		for tag in tags:
			if tag in file:
				tag_count += 1
		
		if tag_count > selected_schema_tag_count:
			
			selected_schema = file
			selected_schema_tag_count = tag_count
	
	dir.list_dir_end()
	
	
	var schema_animation_player = load(schemas_dir + selected_schema).instance()
	animation_list = schema_animation_player.get_animation_list()
	
	for animation_name in animation_list:
		
		var animation_res = schema_animation_player.get_animation(animation_name)
		animation_player.add_animation(animation_name, animation_res)
	
	
	animation = animation_list[0]