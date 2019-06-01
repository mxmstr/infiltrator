tool
extends MarginContainer

enum visibility {
	PHYSICAL, 
	REMOTE, 
	INVISIBLE
}

export(visibility) var type
export(int) var priority
export(String) var animation
export(float) var speed = 1.0
export(float) var blend = 0.0
export(float) var dist
export(String, 'Default', 'Interaction') var input_context = 'Default'
export(String, 'Default', 'CenterMenu') var hud_context = 'Default'
export var resets_to = 'Default'
#export(float) var obj_min_angle
#export(float) var obj_max_angle
#export(float) var subj_min_angle
#export(float) var subj_max_angle
#export(String) var input_context
#export(String) var movement_preset
#export(bool) var enable_events
#export(bool) var inherit_subj
#export(bool) var must_be_reset
#export(PoolIntArray) var triggers 

export(PackedScene) var property_display
export(PackedScene) var signal_display

var prop_cache = {}

signal on_property_changed
signal on_enter
signal on_execute
signal on_exit


func is_visible():
	
	return type != visibility.INVISIBLE


func is_exported_var(prop):
	
	return prop.usage == 8199 and not prop.name in ['property_display', 'signal_display']


func cache_props():
	
	pass
#	for prop in get_property_list():
#		if is_exported_var(prop):
#			if prop in prop_cache \
#				and prop_cache[prop] != get(prop):
#			else:
#				prop_cache[prop] = get(prop)
	
#	for prop in get_property_list():
#		if is_exported_var(prop):
#			prop_cache[prop] = get(prop)


func update_props():
	
	for child in $MarginContainer/VBoxContainer.get_children():
		if child is HBoxContainer:
			child.queue_free()
	
	for prop in get_property_list():
		if is_exported_var(prop):
			var child = property_display.instance()
			$MarginContainer/VBoxContainer.add_child(child)
			connect('on_property_changed', child, 'update_value', [self, prop.name])
	
#	var child = property_display.instance()
#	$MarginContainer/VBoxContainer.add_child(child)
#	get_signal_connection_list('on_enter')


func on_script_changed():
	
	pass#get_tree().reload_current_scene();#update_props()


func _can_start():
	
	for child in get_children():
		if child.has_method('_evaluate') and not child._evaluate():
			return false
	
	return true


func enter():
	
	emit_signal('on_enter')
	set_process(true)


func exit():
	
	emit_signal('on_exit')
	set_process(false)


func _enter_tree():
	
	if Engine.editor_hint:
		
		update_props()


func _ready():
	
	visible = Engine.editor_hint
	
	if not Engine.editor_hint:
		set_process(false)


func _process(delta):
	
	if Engine.editor_hint:
		
		#cache_props()
		
		emit_signal('on_property_changed')
		
		$MarginContainer/VBoxContainer/Name.text = name
		rect_size.y = 100
	
	else:
		
		emit_signal('on_execute')
