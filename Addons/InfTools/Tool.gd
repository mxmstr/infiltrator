tool
extends EditorPlugin

const convert_input = 'res://Raw/kungfu/'
const convert_output = 'res://Animations/Human/Kungfu/'
const loadanim_input = 'res://Animations/Player/'

var dock
var selection


func on_selection_changed():
	
	if selection != null:
	
		var selected = selection.get_selected_nodes()

#		if selected.empty():
#			auto_floor = true
#		else:
#			auto_floor = not self in selected


func on_floor_pressed():
	
	if not selection.get_selected_nodes().empty():
		
		var selected = selection.get_selected_nodes()[0]
		
		if selected is PhysicsBody:
			
			var ray = RayCast.new()
			selected.add_child(ray)
			ray.global_transform = selected.global_transform
			ray.translate(Vector3(0, 0.1, 0)) 
			ray.cast_to = Vector3(0, -100, 0)
			ray.force_raycast_update()
			
			if ray.get_collider() is PhysicsBody:
				selected.translation = ray.get_collision_point()
			
			ray.queue_free()
	#		if $RayCast.get_collider() != null:
	#			translation = $RayCast.get_collision_point()


func on_convert_pressed():
	
	var files = []
	var dir = Directory.new()
	dir.open(convert_input)
	dir.list_dir_begin()
	
	while true:
		
		var file = dir.get_next()
		
		if file == '':
			break
			
		elif not file.begins_with('.') and file.ends_with('.dae'):
			
			var anim_source = load(convert_input + file).instance().get_node('AnimationPlayer').get_animation('default')
			file = file.replace('.dae', '')
			ResourceSaver.save(convert_output + file + '.tres', anim_source)
				
	dir.list_dir_end()


func on_loadanim_pressed():
	
	if not selection.get_selected_nodes().empty():
		
		var selected = selection.get_selected_nodes()[0]
		
		if selected is AnimationPlayer:
			
			var files = []
			var dir = Directory.new()
			dir.open(loadanim_input)
			dir.list_dir_begin()
			
			while true:
				
				var file = dir.get_next()
				
				if file == '':
					break
					
				elif not file.begins_with('.') and file.ends_with('.tres'):
					
					var anim_source = load(loadanim_input + file)
					file = file.replace('.tres', '')
					selected.add_animation(file, anim_source)
						
			dir.list_dir_end()


func _ready():
	
	pass


func _enter_tree():
	
	dock = preload("res://Addons/InfTools/Toolbox.tscn").instance()
	dock.get_node('Floor').connect('button_down', self, 'on_floor_pressed')
	dock.get_node('Convert').connect('button_down', self, 'on_convert_pressed')
	dock.get_node('LoadAnim').connect('button_down', self, 'on_loadanim_pressed')
	
	selection = EditorPlugin.new().get_editor_interface().get_selection()
	selection.connect('selection_changed', self, 'on_selection_changed')
	
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, dock)


func _exit_tree():
	
	remove_control_from_docks(dock)
	dock.free()