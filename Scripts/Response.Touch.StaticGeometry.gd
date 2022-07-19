extends 'res://Scripts/Response.gd'


func _on_stimulate(stim, data):
	
	if stim == 'Touch':
		
		if data.source._has_tag('Bullet'):
			
			data.source.translation = data.position
			
			#Meta.AddActor('Particles/Smoke', owner.translation)
			var sparks = Meta.AddActor('Particles/Sparks', data.source.translation, data.source.rotation)# null, data.direction)
			sparks.rotate_y(deg2rad(180))
			
			Meta.DestroyActor(data.source)
		
		tree_node._reflect()
