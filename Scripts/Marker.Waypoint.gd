@tool
extends Node3D

@export var next: NodePath : set = on_next_changed

var line_material = StandardMaterial3D.new()
var selection = null
var auto_floor = false
var moving = false
var last_position = Vector3(0, 0, 0)

var Editor_Map #/@@5/@@6/@@14/@@16/@@20/@@24/@@25/@@26/@@42/@@43/@@50/@@51/@@6457/@@6323/@@6324/@@6325/@@6326/@@6327/@@6328/Game/Static/Map'

signal position_changed
signal next_position_changed


func on_next_changed(new_next):
	
	if next != null and has_node(next) and get_node(next).is_connected('position_changed',Callable(self,'on_next_moved')):
		get_node(next).disconnect('position_changed',Callable(self,'on_next_moved'))
	
	next = new_next
	
	if next != null and has_node(next):
		get_node(next).connect('position_changed',Callable(self,'on_next_moved'))
	
	emit_signal('position_changed')


func on_next_moved():
	
	emit_signal('next_position_changed')
#	if not get_node(next).is_connected('position_changed',Callable(Editor_Nav,'update_waypoint_path')):
#		get_node(next).connect('position_changed',Callable(Editor_Nav,'update_waypoint_path').bind(self))


func on_selection_changed():
	
	if selection != null:
	
		var selected = selection.get_selected_nodes()
		
		if selected.is_empty():
			auto_floor = true
		else:
			auto_floor = not self in selected


func get_next_ref():
	
	return get_node(next)


func floor_self():
	
	$RayCast3D.force_raycast_update()
	if $RayCast3D.get_collider() != null:
		position = $RayCast3D.get_collision_point()


func _enter_tree():
	
	pass
#	selection = EditorPlugin.new().get_editor_interface().get_selection()
#	selection.connect('selection_changed',Callable(self,'on_selection_changed'))


#func _ready():
#
#	on_next_changed(next)
#
##	selection = EditorPlugin.new().get_editor_interface().get_selection()
##	selection.connect('selection_changed',Callable(self,'on_selection_changed'))
#
#	if Engine.editor_hint:
#
#		var Nav = $'/root/EditorNode'.find_child('Map', true, false)
#
#		if not is_connected('position_changed',Callable(Nav,'update_waypoint_path')):
#			connect('position_changed',Callable(Nav,'update_waypoint_path').bind(self))
#
#		if not is_connected('next_position_changed',Callable(Nav,'update_waypoint_path')):
#			connect('next_position_changed',Callable(Nav,'update_waypoint_path').bind(self))
#
#	visible = Engine.editor_hint
#
#
#func _process(delta):
#
#	if Engine.editor_hint:
#
#		if position != last_position:
#			moving = true
#		elif moving:
#			emit_signal('position_changed')
#			floor_self()
#			moving = false
#
#		last_position = position
#
#
#		var self_pos = $MeshPivot/MeshInstance3D.global_transform.origin
#
#		if next == null:
#			$MeshPivot.rotation_degrees = Vector3(0, 0, 0)
#		else:
#			var next_node = get_node(next)
#			var target_pos = next_node.get_node('MeshPivot/MeshInstance3D').global_transform.origin
#			target_pos.y = self_pos.y
#
#			#$MeshPivot.look_at(target_pos, Vector3(0, 1, 0))
#			#$MeshPivot.rotate_object_local(Vector3(1, 0, 0), deg_to_rad(90))
#
#		$MeshPivot/MeshInstance3D.rotate_object_local(Vector3(0, 1, 0), delta * 5)
#
#
#		if auto_floor:
#			pass
