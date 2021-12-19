extends Control

export(NodePath) var viewport

var radar_dots = []
var radius_x
var radius_y
var ammo_container

onready var radar = get_node('Radar')#.find_node('Sprite')
onready var radar_dot = load('res://Scenes/UI/HUD.RadarDot.tscn')

onready var crosshair = get_node('Crosshair')
onready var ammo = get_node('Ammo')
onready var health = get_node('Health/ProgressBar')
onready var righthand = owner.get_node('../RightHandContainer')
onready var stamina = owner.get_node('../Stamina')
onready var camera = owner.get_node('../CameraRig/Camera')
onready var camera_raycast_target = owner.get_node('../CameraRaycastStim/Target')


func _on_damaged(hp):
	
	health.value = hp


func _on_ammo_added(container, item):
	
	_refresh_ammo()


func _on_ammo_removed(container, item):
	
	_refresh_ammo()


func _on_item_added(container, item):
	
	if item._has_tag('Firearm'):
		
		ammo.show()
		
		if ammo_container:
			ammo_container.disconnect('item_added', self, '_on_ammo_added')
			ammo_container.disconnect('item_removed', self, '_on_ammo_removed')
			ammo_container = null
		
		_refresh_ammo()


func _on_item_removed(container, item):
	
	if ammo_container:
		ammo_container.disconnect('item_added', self, '_on_ammo_added')
		ammo_container.disconnect('item_removed', self, '_on_ammo_removed')
		ammo_container = null
	
	ammo.hide()


func _is_container(node):
	
	if node.get_script() != null:
		
		var script_name = node.get_script().get_path().get_file()
		return script_name == 'Prop.Container.gd'
	
	return false


func _get_ammo_container(item):
	
	var required_tags = item.get_node('Magazine').required_tags_dict.keys()
	var container
	var best_tag_count = 0
	
	for prop in owner.owner.get_children():
		
		if _is_container(prop):
			
			var tag_count = 0
			
			for required_tag in required_tags:
				if required_tag in prop.required_tags_dict.keys():
					tag_count += 1
			
			if tag_count > best_tag_count:
				
				container = prop
				best_tag_count = tag_count
	
	return container


func _refresh_ammo():
	
	if righthand._is_empty():
		
		ammo.hide()
		return
	
	
	if not ammo_container:
		
		ammo_container = _get_ammo_container(righthand.items[0])
		ammo_container.connect('item_added', self, '_on_ammo_added')
		ammo_container.connect('item_removed', self, '_on_ammo_removed')
		
		if not righthand.items[0].get_node('Magazine').is_connected('item_removed', self, '_on_ammo_removed'):
			righthand.items[0].get_node('Magazine').connect('item_removed', self, '_on_ammo_removed')
	
	var inv_ammo = ammo_container.items.size()
	var chamber_ammo = 1 if righthand.items[0].get_node('Chamber').items.size() else 0
	var mag_ammo = righthand.items[0].get_node('Magazine').items.size()
	
	ammo.text = str(chamber_ammo + mag_ammo) + ' | ' + str(inv_ammo)


func _notification(what):
	
	if what == NOTIFICATION_ENTER_TREE:
		
		pass#set_viewport(get_node(viewport))


func _ready():
	
	stamina.connect('damaged', self, '_on_damaged')
	health.value = stamina.hp
	
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
	
	
	ammo.hide()
	righthand.connect('item_added', self, '_on_item_added')
	righthand.connect('item_removed', self, '_on_item_removed')


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
	
	
	crosshair.rect_position = camera.unproject_position(camera_raycast_target.global_transform.origin) - crosshair.rect_pivot_offset
#	if owner.owner.player_index == 0:
#		prints(screen_pos)
	#crosshair.rect_position = screen_pos
	
