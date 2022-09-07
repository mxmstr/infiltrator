extends 'res://Scripts/Response.gd'


func _on_stimulate(stim, data):
	
	if stim == 'Touch':
		
		if data.source._has_tag('Bullet'):
			
			ActorServer.Teleport(data.source, data.position)
			
			#Meta.AddActor('Particles/Smoke', owner.translation)
			var sparks = ActorServer.Create(
				'Particles/Sparks', 
				data.source.translation, 
				data.source.rotation.rotated(data.source.transform.basis.y, PI / 2)
				)
			
			#sparks.rotate_y(deg2rad(180))
			
			#ActorServer.Destroy(data.source)
		
		tree_node._reflect()
