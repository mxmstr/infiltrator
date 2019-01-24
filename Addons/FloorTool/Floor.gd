tool
extends EditorPlugin

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


func _ready():
	
	pass


func _enter_tree():
	
	dock = preload("res://addons/FloorTool/FloorTool.tscn").instance()
	dock.get_node('Button').connect('button_down', self, 'on_floor_pressed')
	
	selection = EditorPlugin.new().get_editor_interface().get_selection()
	selection.connect('selection_changed', self, 'on_selection_changed')
	
	add_control_to_dock(DOCK_SLOT_LEFT_UL, dock)


func _exit_tree():
	
	remove_control_from_docks(dock)
	dock.free()