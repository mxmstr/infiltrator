extends Control

export(NodePath) var viewport

var radar_dots = []
var radius_x
var radius_y

onready var radar = get_node('Radar')#.find_node('Sprite')
onready var radar_dot = load('res://Scenes/UI/HUD.RadarDot.tscn')


func _notification(what):
	
	if what == NOTIFICATION_ENTER_TREE:
		
		pass#set_viewport(get_node(viewport))


func _ready():
	
	yield(get_tree(), 'idle_frame')
	
	radius_x = radar.rect_size.x / 2
	radius_y = radar.rect_size.y / 2
	
	#set_viewport(get_node(viewport))
	
	if Meta.multi_radar:
		
		for actor in $'/root/Mission/Actors'.get_children():
			
			if actor != owner.owner and actor.get('tags') and actor._has_tag('Human'):
				
				var dot = radar_dot.instance()
				dot.modulate = Color.red
				add_child(dot)
				radar_dots.append([dot, actor])
	
	else:
		
		radar.get_node('TextureRect').hide()


func _process(delta):
	
#	radar_texture.position = rect_size - ((radar_texture.texture.get_size() / 2))
	
	for dot_info in radar_dots:
		
		var dot = dot_info[0]
		var actor = dot_info[1]
		
		var distance_to = owner.owner.translation.distance_to(actor.translation)
		var direction_to = owner.owner.translation.direction_to(actor.translation) * -distance_to
		direction_to = owner.owner.transform.basis.xform_inv(direction_to) * 20.0
		direction_to.y = 0
		
		if direction_to.length() > radius_x:
			direction_to = direction_to.normalized() * radius_x
		
		var actor_position = Vector2(radius_x + direction_to.x, radius_y + direction_to.z)
		
		dot.position = radar.rect_global_position + actor_position
