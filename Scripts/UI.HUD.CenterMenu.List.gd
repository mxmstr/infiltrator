extends VBoxContainer

export(Color) var color_select
export(Color) var color_default
export(Color) var color_cancel
export(PackedScene) var list_item

var update = true
var interactions = []
var select_index = 0

onready var parent = $'../../../../../../'
onready var raycast = parent.get_node('PlayerControl/Viewport/Camera/RayCast')

signal option_selected


func _has_interactions():
	
	return len(get_children()) > 0


func _scroll_up():
	
	select_index = max(0, select_index - 1)
	_highlight_child()


func _scroll_down():
	
	select_index = min(len(get_children()) - 1, select_index + 1)
	_highlight_child()


func _select():
	
	if _has_interactions():
		
		if select_index < len(get_children()) - 1:
			var interaction = get_children()[select_index].text
			emit_signal('option_selected', interaction)
				
		select_index = 0
		_highlight_child()


func _highlight_child():
	
	var children = get_children()
	
	if len(children) > 0:
	
		for index in range(len(children)):
			if index == select_index:
				children[index].set('custom_colors/font_color', color_select)
			elif index == len(children) - 1:
				children[index].set('custom_colors/font_color', color_cancel)
			else:
				children[index].set('custom_colors/font_color', color_default)


func _update_interactions(interactions):
	
	for child in get_children():
		child.name = child.name + '_'
		child.free()
	
	if len(interactions) > 0:
		
		for interaction in interactions:
			var child = list_item.instance()
			child.text = interaction
			add_child(child)
		
		var child = list_item.instance()
		child.text = 'Cancel'
		add_child(child)
		
	select_index = 0
	
	_highlight_child()


func _ready():
	
	raycast.connect('changed_selection', self, '_update_interactions')
	connect('option_selected', raycast, '_on_option_selected')


func _process(delta):
	
	pass