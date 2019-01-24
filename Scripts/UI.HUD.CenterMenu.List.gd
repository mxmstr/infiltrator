extends VBoxContainer

export(Color) var color_select
export(Color) var color_default
export(PackedScene) var list_item

var update = true
var selection
var select_index = 0


func has_interactions():
	
	return len(get_children()) > 0


func scroll_up():
	
	select_index = max(0, select_index - 1)
	highlight_child()


func scroll_down():
	
	select_index = min(len(get_children()) - 1, select_index + 1)
	highlight_child()


func select():
	
	if has_interactions():
		
		selection.get_node('Interaction').start_interaction(
			get_children()[select_index].text
			)
			
		select_index = 0
		highlight_child()


func highlight_child():
	
	var children = get_children()
	
	for index in range(len(children)):
		if index == select_index:
			children[index].set('custom_colors/font_color', color_select)
		else:
			children[index].set('custom_colors/font_color', color_default)


func update_interactions(_selection):
	
	selection = _selection
	
	for child in get_children():
		child.queue_free()
	
	if selection != null and selection.has_node('Interaction'):
		
		var interactions = selection.get_node('Interaction').get_children()
		
		for interaction in interactions:
			var child = list_item.instance()
			child.text = interaction.name
			add_child(child)
		
		var child = list_item.instance()
		child.text = 'Cancel'
		add_child(child)
	
	select_index = 0
	
	highlight_child()


func _ready():
	
	pass


func _process(delta):
	
	pass