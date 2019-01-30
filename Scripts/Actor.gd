tool
extends StaticBody

const animations_root = 'res://Animations/'

export(PackedScene) var model setget set_model
export(String) var animations
export(String) var behaviors



func set_model(new_model):
	
	model = new_model
	
	if Engine.editor_hint:
		
		if model != null:
			var s_new = model.instance().get_child(0).duplicate()
			$Model.add_child(s_new)


func replace_model():
	
	if model != null:
		
		var s_old = $Model/SkeletonName
		s_old.name = 'SkeletonName2'
		s_old.queue_free()
		
		var s_new = model.instance().get_child(0).duplicate()
		$Model.add_child(s_new)


func add_animations():
	
	if animations != null:
		
		var files = []
		var dir = Directory.new()
		dir.open(animations_root + animations)
		dir.list_dir_begin()
		
		while true:
			var file = dir.get_next()
			if file == '':
				break
			elif not file.begins_with('.'):
				var anim_name = file.replace('.anim', '').replace('.tres', '')
				var anim_source = load(animations_root + animations + '/' + file)
				$Model/AnimationPlayer.add_animation(anim_name, anim_source)
				files.append(file)
				
		dir.list_dir_end()


func _ready():
	
	if not Engine.editor_hint:
		
		replace_model()
		add_animations()
