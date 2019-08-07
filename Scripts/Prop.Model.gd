tool
extends Spatial

const animations_root = 'res://Animations/'

export(String) var animations


func _listen_for_anim_changes():
	
	$'../Behavior'.connect(
		'animation_changed', 
		$AnimationPlayer, 
		'play'
		) if has_node('../Behavior') else null


func _add_animations():
	
	if animations != null:
		
		var files = []
		var dir = Directory.new()
		dir.open(animations_root + animations)
		dir.list_dir_begin()
		
		while true:
			var file = dir.get_next()
			if file == '':
				break
			elif not file.begins_with('.') and file.ends_with('.tres'):
				var anim_name = file.replace('.anim', '').replace('.tres', '')
				var anim_source = load(animations_root + animations + '/' + file)
				$AnimationPlayer.add_animation(anim_name, anim_source)
				files.append(file)
				
		dir.list_dir_end()


func _ready():
	
	if not Engine.editor_hint:
		
		_add_animations()
		_listen_for_anim_changes()