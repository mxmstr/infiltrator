extends AnimationTree


func _ready():
	
	if Engine.editor_hint: return
	
	if not has_meta('unique'):
		Inf._make_unique(self)
		return
	
	
	if tree_root.has_method('_ready'):
		tree_root._ready(self, null, 'parameters/', '')
	
	active = true