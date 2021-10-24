extends Control

export(NodePath) var viewport

var radar_dots = []

onready var radar = get_node('Radar')#.find_node('Sprite')
onready var radar_dot = load('res://Scenes/UI/HUD.RadarDot.tscn')


func _notification(what):
	
	if what == NOTIFICATION_ENTER_TREE:
		
		pass#set_viewport(get_node(viewport))


func _ready():
	
	yield(get_tree(), 'idle_frame')
	
	#set_viewport(get_node(viewport))
	
	for actor in $'/root/Mission/Actors'.get_children():
		
		if actor != owner.owner and actor.get('tags') and actor._has_tag('Human'):
			
			var dot = radar_dot.instance()
			dot.modulate = Color.red
			add_child(dot)
			radar_dots.append([dot, actor])


func _process(delta):
	
#	radar_texture.position = rect_size - ((radar_texture.texture.get_size() / 2))
	
	for dot_info in radar_dots:
		
		var dot = dot_info[0]
		var actor = dot_info[1]
		
		var distance_to = owner.owner.translation.distance_to(actor.translation)
		var direction_to = owner.owner.translation.direction_to(actor.translation) * -distance_to
		direction_to = owner.owner.transform.basis.xform_inv(direction_to) * 10.0
		var actor_position = Vector2((radar.rect_size.x / 2) + direction_to.x, (radar.rect_size.y / 2) + direction_to.z)
#
#		var translation = (actor.translation - owner.owner.translation) * 0.1
#		var dot_position = Vector2((rect_size.x / 2) + translation.x, (rect_size.y / 2) + translation.z)
		
#		var radar_scale = radar.rect_size / get_viewport_rect().size * 50
#		var obj_pos = Vector2(direction_to.x, direction_to.z) * radar_scale + radar.rect_size / 2
		
		var radar_center = radar.rect_global_position# - (radar.rect_size / 2)# - (radar_texture.rect_size / 2)
		dot.position = actor_position + radar_center
#		print(actor.name, dot_position)
		
	
	#radar_texture
