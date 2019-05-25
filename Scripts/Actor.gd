tool
extends PhysicsBody

const animations_root = 'res://Animations/'
const behaviors_root = 'res://Scenes/Behaviors/'

export(PackedScene) var model setget set_model
export(PackedScene) var collision setget set_collision
export(String) var animations
export(String) var behaviors
export(String) var default_behavior


func set_model(new_model):
	
	model = new_model
	
	if Engine.editor_hint:
		
		if model != null:
			var s_new = model.instance().get_child(0).duplicate()
			$Model.add_child(s_new)


func set_collision(new_collision):
	
	collision = new_collision
	
#	if collision != null:
#		$CollisionShape.shape = load(collision)


func replace_model():
	
	if model != null:
		
		var s_old = $Model/SkeletonName
		s_old.name = 'SkeletonName2'
		s_old.queue_free()
		
		var root = model.instance()
		var s_new = root.get_child(0).duplicate()
		$Model.add_child(s_new)
		
		root.queue_free()


func replace_collision():
	
	if collision != null:
		
		var root = collision.instance()
		var shape = root.get_node('CollisionShape').duplicate()
		$Model.add_child(shape)
		
		shape_owner_add_shape(create_shape_owner(shape), shape.shape)
		
		root.queue_free()
#		var c_old = $CollisionShape
#		c_old.name = 'CollisionShape2'
#		c_old.queue_free()
#
#		var c_new = collision.instance()
#		add_child(c_new)


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


func add_interactions():
	
	if behaviors != null:
		
		$Behavior.set_behavior(default_behavior)


func _send_message(path, message, params):
	
	get_node(path).call(message, [params])


func _ready():
	
	if not Engine.editor_hint:
		
		replace_model()
		replace_collision()
		add_animations()
		add_interactions()
